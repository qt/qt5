#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# libusb-1.0 is needed by qt-apps/qdb

. "$PSScriptRoot\helpers.ps1"

$archive = Get-DownloadLocation "libusb-1.0.26.7z"

$libusb_location = "C:\Utils\libusb-1.0"

Copy-Item \\ci-files01-hki.ci.qt.io\provisioning\libusb-1.0\libusb-1.0.26.7z $archive
Verify-Checksum $archive "89b50c7d6085350ed809a12b19131ff4f608b2f2"

Extract-7Zip $archive $libusb_location

# Tell qt-apps/qdb build system where to find libusb
Set-EnvironmentVariable "LIBUSB_PATH" $libusb_location

Write-Output "libusb = libusb-1.0.26" >> ~/versions.txt
