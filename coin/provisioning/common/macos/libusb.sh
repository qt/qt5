#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install libusb
set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
brew install libusb
read -r -a arr <<< "$(brew list --versions libusb)"
version=${arr[1]}
echo "libusb = $version" >> ~/versions.txt

mkdir /tmp/arm64/
mkdir /tmp/amd64/

case $(sw_vers -productVersion) in
    11*) codename=big_sur;;
    12*) codename=monterey;;
    13*) codename=ventura;;
    14*) codename=sonoma;;
esac

brew fetch --bottle-tag=arm64_"${codename}" libusb
brew fetch --bottle-tag="${codename}" libusb
tar xf "$(brew --cache --bottle-tag=arm64_"${codename}" libusb)" -C /tmp/arm64/
tar xf "$(brew --cache --bottle-tag="${codename}" libusb)" -C /tmp/amd64
for f in /tmp/arm64/libusb/"$version"/lib/* ; do
    if lipo -info "$f" >/dev/null 2>&1; then
        file="$(basename "$f")"
        lipo -create -output "$(brew --cellar)/libusb/$version/lib/$file" \
            "/tmp/arm64/libusb/$version/lib/$file" \
            "/tmp/amd64/libusb/$version/lib/$file"
    fi
done
