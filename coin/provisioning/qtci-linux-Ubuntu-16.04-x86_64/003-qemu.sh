#!/usr/bin/env bash
#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

set -e
# build latest qemu to usermode
sudo apt-get -y install automake autoconf libtool

tempDir=$(mktemp -d) || echo "Failed to create temporary directory"
git clone git://git.qemu.org/qemu.git "$tempDir"
cd "$tempDir"

#latest commit from the master proven to work
git checkout c7f1cf01b8245762ca5864e835d84f6677ae8b1f
git submodule update --init pixman
./configure --target-list=arm-linux-user --static
make
sudo make install
rm -rf "$tempDir"

# Enable binfmt support
sudo apt-get -y install binfmt-support

# Install qemu binfmt
sudo update-binfmts --package qemu-arm --install arm \
/usr/local/bin/qemu-arm \
--magic \
"\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00" \
--mask \
"\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"

# First test using QFont fails if fonts-noto-cjk is installed. This happens because
# running fontcache for that font takes > 5 mins when run on QEMU. Running fc-cache
# doesn't help since host version creates cache for a wrong architecture and running
# armv7 fc-cache segfaults on QEMU.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y remove fonts-noto-cjk

# If normal fontconfig paths are used, qemu parses what ever files it finds from
# the toolchain sysroot and the rest from the system fonts. Fix by copying the
# system font configurations to a location which prefix that can't be found from
# the toolchain sysroot. Links must also be dereferenced or their targets remain
# pointing to the toolchain sysroot.
QEMU_FONTCONFPATH=~/qemu_fonts
QEMU_FONTCONFFILE=$QEMU_FONTCONFPATH/fonts.qemu.conf
mkdir -p $QEMU_FONTCONFPATH
cp -Lr /etc/fonts/* $QEMU_FONTCONFPATH
sed $QEMU_FONTCONFPATH/fonts.conf -e "s:conf.d:$QEMU_FONTCONFPATH/conf.d:" > $QEMU_FONTCONFFILE
echo "export QEMU_SET_ENV=\"FONTCONFIG_FILE=$QEMU_FONTCONFFILE,FONTCONFIG_PATH=$QEMU_FONTCONFPATH\"" >> ~/.profile
