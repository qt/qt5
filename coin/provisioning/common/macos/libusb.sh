#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# Install libusb
set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
brew install libusb
read -r -a arr <<< $(brew list --versions libusb)
version=${arr[1]}
echo "libusb = $version" >> ~/versions.txt

mkdir /tmp/arm64/
mkdir /tmp/amd64/

case $(sw_vers -productVersion) in
    11*) codename=big_sur;;
    12*) codename=monterey;;
    13*) codename=ventura;;
esac

brew fetch --bottle-tag=arm64_${codename} libusb
brew fetch --bottle-tag=${codename} libusb
tar xf $(brew --cache --bottle-tag=arm64_${codename} libusb) -C /tmp/arm64/
tar xf $(brew --cache --bottle-tag=${codename} libusb) -C /tmp/amd64
for f in /tmp/arm64/libusb/$version/lib/* ; do
    if lipo -info $f >/dev/null 2>&1; then
        file=$(basename $f)
        lipo -create -output $(brew --cellar)/libusb/$version/lib/$file \
            /tmp/arm64/libusb/$version/lib/$file \
            /tmp/amd64/libusb/$version/lib/$file
    fi
done
