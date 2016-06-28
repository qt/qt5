#############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# Patch QNX SDK due to issues in the standard library.
# The patches are available here:
# http://www.qnx.com/download/feature.html?programid=27555
# A copy of the patch must be in the root of the Coin path in
# provisioning/qnx/patch-660-4367-RS6069_cpp-headers.zip


. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\patch-660-4367-RS6069_cpp-headers.zip"
$sha1 = "57A11FFE4434AD567B3C36F7B828DBB468A9E565"
$tempDir = "C:\temp\qnx_path"

Invoke-WebRequest -UseBasicParsing http://${Env:COIN_WEBSERVER_ADDRESS}/coin/provisioning/qnx/patch-660-4367-RS6069_cpp-headers.zip -OutFile $zip
Verify-Checksum $zip $sha1
Extract-Zip $zip $tempDir
Copy-Item $tempDir\patches\660-4367\target\* C:\qnx660\target\ -recurse -force
Remove-Item $tempDir -recurse
