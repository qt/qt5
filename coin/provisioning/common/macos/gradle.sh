#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SourceEnvVars.sh
source "${BASH_SOURCE%/*}/../unix/SourceEnvVars.sh"

echo "Caching Gradle distributions and dependencies"

gradle_project_source="${BASH_SOURCE%/*}/../shared/gradle/project"
gradleDistributionMirror="http://ci-files01-hki.ci.qt.io/input/gradle"
gradleInitScript="init.d/nexus-mirror.gradle"

# Route every Gradle repository through the internal Nexus mirror.
mkdir -p "$HOME/.gradle/init.d"
cp "${BASH_SOURCE%/*}/../shared/gradle/$gradleInitScript" "$HOME/.gradle/$gradleInitScript"

# Returns the hash of the Gradle binary distribution for a given Gradle version.
# Gradle calculates the hash as base36(md5(distributionUrl)).
gradleDistributionHash () {
    version="$1"
    propertiesFile="$gradle_project_source/gradle/wrapper/gradle-wrapper.properties"

    # 1. Read the project's distributionUrl.
    distributionUrl=$(grep '^distributionUrl=' "$propertiesFile")
    distributionUrl=${distributionUrl#distributionUrl=}
    # 2. Unescape the Java-properties (e.g. '\:').
    distributionUrl=${distributionUrl//\\:/:}
    # 3. Swap in the requested version while maintaining the distribution URL.
    distributionUrl=${distributionUrl/gradle-[0-9.]*-bin.zip/gradle-$version-bin.zip}

    if command -v md5sum >/dev/null 2>&1; then
        md5Hex=$(printf '%s' "$distributionUrl" | md5sum | awk '{print $1}')
    else
        md5Hex=$(printf '%s' "$distributionUrl" | md5)
    fi

    # Convert the md5 to base36: read it as a number, then repeatedly take the
    # next digit (number % 36) and divide by 36, prepending each digit's character.
    number=$(printf 'ibase=16; %s\n' "$(printf '%s' "$md5Hex" | tr 'a-f' 'A-F')" | bc)
    hash=""
    alphabet="0123456789abcdefghijklmnopqrstuvwxyz"
    while [ "$number" != "0" ]; do
        digit=$(printf '%s %% 36\n' "$number" | bc)
        number=$(printf '%s / 36\n' "$number" | bc)
        hash="${alphabet:$digit:1}$hash"
    done
    printf '%s' "$hash"
}

# Seed a Gradle distribution binary into ~/.gradle from the internal mirror.
seedGradleDistribution () {
    version="$1"
    sha="$2"

    distributionDir="$HOME/.gradle/wrapper/dists/gradle-${version}-bin/$(gradleDistributionHash "$version")"
    if [ -e "$distributionDir/gradle-${version}-bin.zip.ok" ]; then
        return 0
    fi
    mkdir -p "$distributionDir"
    zip="$distributionDir/gradle-${version}-bin.zip"
    url="$gradleDistributionMirror/gradle-${version}-bin.zip"
    DownloadURL "$url" "$url" "$sha" "$zip"
    unzip -q -o "$zip" -d "$distributionDir"
    rm -f "$zip"
    touch "$distributionDir/gradle-${version}-bin.zip.ok"
}

# Populate ~/.gradle/caches by priming the shared project for each Gradle and AGP profile.
cacheGradleProfile () {
    echo "Caching Gradle profile $*"
    tmp="$(mktemp -d)"
    project="$tmp/project"
    cp -r "$gradle_project_source" "$project"

    props="$project/gradle/wrapper/gradle-wrapper.properties"
    for kv in "$@"; do
        case "$kv" in
            gradle=*)
                sed "s#gradle-[0-9.]*-bin.zip#gradle-${kv#*=}-bin.zip#" "$props" > "$props.tmp"
                mv "$props.tmp" "$props"
                ;;
        esac
    done

    toml="$project/gradle/libs.versions.toml"
    for kv in "$@"; do
        case "$kv" in
            gradle=*) ;;
            *)
                key="${kv%%=*}"
                val="${kv#*=}"
                sed "/^\[versions\]/,/^\[/ s/^$key = .*/$key = \"$val\"/" "$toml" > "$toml.tmp"
                mv "$toml.tmp" "$toml"
                ;;
        esac
    done

    sh "$project/gradlew" --project-dir "$project" build
    rm -rf "$tmp"
}

seedGradleDistribution 9.3.1 "b266d5ff6b90eada6dc3b20cb090e3731302e553a27c5d3e4df1f0d76beaff06"
cacheGradleProfile gradle=9.3.1 agp=9.0.0

echo "Cached Gradle distributions and dependencies under $HOME/.gradle."
