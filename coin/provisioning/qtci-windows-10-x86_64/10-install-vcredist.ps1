############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script will install VC Redistributable

$sha1 = "a55510a8c9708b2c68b39cd50bbcaf86e2c885f0"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\VC_redist.x64.exe"
# https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads
$url_official = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
$package = "C:\Windows\Temp\vc_redist.x64.exe"

Download $url_official $url_cache $package
Verify-Checksum $package $sha1
Run-Executable "$package" "/install /quiet /norestart"

Remove-Item -Recurse -Force -Path $package
