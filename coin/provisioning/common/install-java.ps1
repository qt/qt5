############################################################################
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

. "$PSScriptRoot\..\common\helpers.ps1"

# This script will install Java RE
# Official Java RE 7 downloads require Oracle accounts. Using local mirrors only.

$version = "7u7"
if( (is64bitWinHost) -eq 1 ) {
    $arch = "x64"
    $sha1 = "9af03460c416931bdee18c2dcebff5db50cb8cb3"
}
else {
    $arch = "i586"
    $sha1 = "f76b1be20b144b1ee1d1de3255edb0a6b57d0219"
}

$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\jre-" + $version + "-windows-" + $arch + ".exe"
$javaPackage = "C:\Windows\Temp\java-$version.exe"

Copy-Item $url_cache $javaPackage
cmd /c "$javaPackage /s SPONSORS=0"
echo "Cleaning $javaPackage.."
Remove-Item -Recurse -Force "$javaPackage"
echo "Java = $version $arch" >> ~\versions.txt
