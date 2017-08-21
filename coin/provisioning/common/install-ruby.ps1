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

# This script will install Ruby

$version = "2.2.6"
if( (is64bitWinHost) -eq 1 ) {
    $arch = "-x64"
    $sha1 = "4D0E366F0264CDED174E5842B2435E22B81FB57A"
}
else {
    $arch = ""
    $sha1 = "8649309fffe9c746ad5549d3f7b70490806e95df"
}
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\rubyinstaller-" + $version + $arch + ".exe"
$url_official = "https://bintray.com/oneclick/rubyinstaller/download_file?file_path=rubyinstaller-" + $version + $arch + ".exe"
$rubyPackage = "C:\Windows\Temp\rubyinstaller-$version.exe"

Download $url_official $url_cache $rubyPackage
Verify-Checksum $rubyPackage $sha1
cmd /c "$rubyPackage /silent"

echo "Cleaning $rubyPackage.."
Remove-Item -Recurse -Force "$rubyPackage"

$oldPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
[Environment]::SetEnvironmentVariable("Path", $oldPath + ";C:\Ruby22-x64\bin", [EnvironmentVariableTarget]::Machine)

echo "Ruby = $version" >> ~\versions.txt
