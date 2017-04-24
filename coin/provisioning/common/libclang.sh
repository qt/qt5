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

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# This same script is used to provision libclang to Linux and macOS.
# In case of Linux, we expect to get the values as args
set -e

BASEDIR=$(dirname "$0")
. $BASEDIR/sw_versions.txt
url=$1
sha1=$2
version=$3
if [ $# -eq 0 ]
  then
    # The default values are for macOS package
    echo "Using macOS defaults"
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${version//\./}-mac.7z"
    sha1="4781d154b274b2aec99b878c364f0ea80ff00a80"
fi

zip="libclang.7z"
destination="/usr/local/libclang-$version"

curl --fail -L --retry 5 --retry-delay 5 -o "$zip" "$url"
_shasum=sha1sum
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "DARWIN"
    _shasum=/usr/bin/shasum
fi
echo "$sha1  $zip" | $_shasum --check
7z x $zip -o/tmp/
rm -rf $zip

sudo mv /tmp/libclang $destination

echo "export LLVM_INSTALL_DIR=$destination" >> ~/.bash_profile
echo "libClang = $version" >> ~/versions.txt
