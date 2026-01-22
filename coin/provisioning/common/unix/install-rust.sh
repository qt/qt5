#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install rust toolchain
set -ex

PROVISIONING_DIR="$(dirname "$0")/../../"

# shellcheck source=./../unix/common.sourced.sh
source "${BASH_SOURCE%/*}/../unix/common.sourced.sh"
# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=./../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="1.92.0"
sourceName="rustc-$version-src"
sourceFile="$sourceName.tar.xz"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/rust/$sourceFile"
officialUrl="https://static.rust-lang.org/dist/$sourceFile"
sourcesSHA256="ebee170bfe4c4dfc59521a101de651e5534f4dae889756a5c97ca9ea40d0c307"

function BuildRust() {
    buildFolder=$1
    installPrefix=$2
    target=$3
    channel=$4
    outputTarball=$5
    tmpFolder=$6

    targetFile=$tmpFolder/$sourceFile
    srcFolder=$tmpFolder/$sourceName

    if [ ! -d "$srcFolder" ]; then
        DownloadURL $cachedUrl $officialUrl $sourcesSHA256 $targetFile
        tar -C "$tmpFolder" -Jxf "$targetFile"
    fi

    mkdir -p "$buildFolder"
    cd "$buildFolder"

    $srcFolder/configure            \
        --prefix=$installPrefix     \
        --sysconfdir=etc            \
        --enable-llvm-link-shared   \
        --enable-profiler           \
        --disable-cargo-native-static \
        --disable-vendor            \
        --disable-docs              \
        --disable-lld               \
        --target=$target            \
        --release-description=QtCI  \
        --release-channel=$channel

    echo "Building rust"
    python $srcFolder/x.py dist

    # x.py doesnt like running as root so install under our temporary folder for now
    export DESTDIR=$tmpFolder

    echo "Installing rust"
    python $srcFolder/x.py install

    # rustc must be in path for cargo to work
    OLDPATH=$PATH
    export PATH=$DESTDIR$installPrefix/bin:$PATH

    echo "Installing rust bindgen tool."
    $tmpFolder$installPrefix/bin/cargo install bindgen-cli --root $DESTDIR$installPrefix

    tar -czf "$outputTarball" -C "$DESTDIR$installPrefix"  .

    rm -rf "$buildFolder"
    export PATH=$OLDPATH
    unset DESTDIR
}

function InstallRust() {
    buildFolder=$1
    installPrefix=$2
    target=$3
    channel=$4
    prebuiltSHA256=$5

    tmpFolder=$(mktemp -d)

    # e.g rust-1.92.0-macos-arm64-prebuilt.tar.gz or rust-1.92.0-macos-amd64-prebuilt.tar.gz
    prebuiltFile="rust-$version-$PROVISIONING_OS-$PROVISIONING_ARCH-prebuilt.tar.gz"
    prebuiltRust="http://ci-files01-hki.ci.qt.io/input/rust/$prebuiltFile"
    prebuiltTarget="$tmpFolder$prebuiltFile"

    DownloadURL $prebuiltRust "" $prebuiltSHA256 $prebuiltTarget $tmpFolder || (
        if [ $COIN_RUNS_IN_QT_COMPANY = true ]
        then
            echo "Fetching prebuilt rust failed."
            exit 1
        else
            echo "Fetching prebuilt rust failed. Building from sources."
            BuildRust $buildFolder $installPrefix $target $channel $prebuiltTarget
        fi
    )

    sudo mkdir "$installPrefix"
    sudo tar -xzf "$prebuiltTarget" -C "$installPrefix"
    rm -rf "$prebuiltTarget"
    rm -rf "$tmpFolder"

    SetEnvVar "PATH" "$installPrefix/bin:\$PATH"

    echo "Rust = $version" >> ~/versions.txt
}
