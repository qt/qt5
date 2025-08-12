#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will
#   1) Clone the vcpkg repo   - https://github.com/microsoft/vcpkg/tags
#   2) Install the vcpkg-tool - https://github.com/microsoft/vcpkg-tool/tags

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"

vcpkgVersion=$(grep 'vcpkg_version=' "${BASH_SOURCE%/*}/../shared/vcpkg_version.txt" | cut -d '=' -f 2)

vcpkgRoot="$HOME/vcpkg-$vcpkgVersion"
vcpkgRepo=$(head -n 1 "${BASH_SOURCE%/*}/../shared/vcpkg_registry_mirror.txt")

echo "Cloning the vcpkg repo"
git clone "$vcpkgRepo" "$vcpkgRoot"
git -C "$vcpkgRoot" checkout "tags/$vcpkgVersion"

echo "Install the vcpkg-tool"
releaseTagFile="${BASH_SOURCE%/*}/../shared/vcpkg_tool_release_tag.txt"
for line in $(cat "$releaseTagFile")
do
    IFS='='
    read -ra keyValue <<< "$line"
    unset IFS

    case "${keyValue[0]}" in
        "vcpkg_tool_release_tag")
            vcpkgToolReleaseTag=${keyValue[1]}
            ;;
        "unix_checksum")
            vcpkgToolChecksum=${keyValue[1]}
            ;;
    esac
done

if [ -z vcpkgToolReleaseTag ]
then
    echo "Unable to read release tag from $releaseTagFile"
    echo "Content:"
    cat $releaseTagFile
    exit 1
fi

if [ -z vcpkgToolChecksum ]
then
    echo "Unable to read vcpkg tool Checksum from $releaseTagFile"
    echo "Content:"
    cat $releaseTagFile
    exit 1
fi

nonDottedReleaseTag=${vcpkgToolReleaseTag//-/}

vcpkgToolOfficialUrl="https://github.com/microsoft/vcpkg-tool/archive/refs/tags/$vcpkgToolReleaseTag.tar.gz"
vcpkgToolCacheUrl="http://ci-files01-hki.ci.qt.io/input/vcpkg/vcpkg-tool-$nonDottedReleaseTag.tar.gz"
vcpkgToolSourceFolder="$HOME/vcpkg-tool-$vcpkgToolReleaseTag"
vcpkgToolBuildFolder="$HOME/vcpkg-tool-$vcpkgToolReleaseTag/build"

InstallFromCompressedFileFromURL "$vcpkgToolCacheUrl" "$vcpkgToolOfficialUrl" "$vcpkgToolChecksum" "$HOME" ""
cmake -S "$vcpkgToolSourceFolder" -B "$vcpkgToolBuildFolder" -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DVCPKG_DEVELOPMENT_WARNINGS=OFF
cmake --build "$vcpkgToolBuildFolder" --parallel

cp "$vcpkgToolBuildFolder/vcpkg" "$vcpkgRoot/"
rm -rf "$vcpkgToolSourceFolder"

if [ ! -f "$vcpkgRoot/vcpkg" ]
then
    echo "Can't find $vcpkgRoot/vcpkg."
    exit 1
fi

chmod 755 "$vcpkgRoot/vcpkg"
touch "$vcpkgRoot/vcpkg.disable-metrics"

# Setting VCPKG_ROOT using Set-EnvVar makes the variable only
# available during build time. In order to make it available during the
# provisioning, we need to directly set it via $env:VCPKG_ROOT as well.
SetEnvVar "VCPKG_ROOT" "$vcpkgRoot"
export VCPKG_ROOT="$vcpkgRoot"

# Set a source for vcpkg Binary and Asset Cache
# The `coin/provisioning/common/<platform>/mount-vcpkg-cache-drive.sh` script is
# mounting the SMB share located in `vcpkg-server.ci.qt.io/vcpkg` to
# $HOME/vcpkg-cache/
export VCPKG_BINARY_SOURCES="files,$HOME/vcpkg-cache/binaries,readwrite"
export X_VCPKG_ASSET_SOURCES="x-azurl,file:///$HOME/vcpkg-cache/assets,,readwrite"

SetEnvVar VCPKG_BINARY_SOURCES "$VCPKG_BINARY_SOURCES"
SetEnvVar X_VCPKG_ASSET_SOURCES "$X_VCPKG_ASSET_SOURCES"

echo "vcpkg = $vcpkgVersion" >> ~/versions.txt
