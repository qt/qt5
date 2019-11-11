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
############################################################################
. "$PSScriptRoot\helpers.ps1"

# This script will install gnuwin32

$prog = "gnuwin32"
$zipPackage = "$prog.zip"
$temp = "$env:tmp"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/$prog/$zipPackage"
$externalUrl = "http://download.qt.io/development_releases/$prog/$zipPackage"
Download $externalUrl $internalUrl "$temp\$zipPackage"
Verify-Checksum "$temp\$zipPackage" "d7a34a385ccde2374b8a2ca3369e5b8a1452c5a5"
Extract-7Zip "$temp\$zipPackage" C:\Utils

Write-Output "$prog qt5 commit sha = 98c4f1bbebfb3cc6d8e031d36fd1da3c19e634fb" >> ~\versions.txt
Prepend-Path "C:\Utils\gnuwin32\bin"
