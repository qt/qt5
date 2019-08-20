############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

. "$PSScriptRoot\helpers.ps1"

# This script installs sed and it's dependencies

$prog = "sed"
$version = "4.2.1"
$sha1 = "dfd3d1dae27a24784d7ab40eb074196509fa48fe"
$dep_sha1 = "f7edbd7152d8720c95d46dd128b87b8ba48a5d6f"
$pkg = "$prog-$version-bin.zip"
$dep_pkg = "$prog-$version-dep.zip"
$cached_url = "http://ci-files01-hki.intra.qt.io/input/windows/gnuwin32/$pkg"
$dep_cached_url = "http://ci-files01-hki.intra.qt.io/input/windows/gnuwin32/$dep_pkg"
$install_location = "c:\Utils\$prog"

$tmp_location = "c:\users\qt\downloads"
Download $cached_url $cached_url "$tmp_location\$pkg"
Verify-Checksum "$tmp_location\$pkg" $sha1 sha1
Download $dep_cached_url $dep_cached_url "$tmp_location\$dep_pkg"
Verify-Checksum "$tmp_location\$dep_pkg" $dep_sha1 sha1

Extract-7Zip "$tmp_location\$pkg" $install_location
Extract-7Zip "$tmp_location\$dep_pkg" $install_location
Remove "$tmp_location\$pkg"
Remove "$tmp_location\$dep_pkg"

Prepend-Path "$install_location\bin"
Write-Output "sed = $version" >> ~/versions.txt
