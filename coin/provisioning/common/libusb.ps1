#############################################################################
#
# Copyright (C) 2017 The Qt Company Ltd.
# Contact: http://www.qt.io/licensing/
#
# This file is part of the provisioning scripts of the Qt Toolkit.
#
# $QT_BEGIN_LICENSE:LGPL21$
# Commercial License Usage
# Licensees holding valid commercial Qt licenses may use this file in
# accordance with the commercial license agreement provided with the
# Software or, alternatively, in accordance with the terms contained in
# a written agreement between you and The Qt Company. For licensing terms
# and conditions see http://www.qt.io/terms-conditions. For further
# information use the contact form at http://www.qt.io/contact-us.
#
# GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser
# General Public License version 2.1 or version 3 as published by the Free
# Software Foundation and appearing in the file LICENSE.LGPLv21 and
# LICENSE.LGPLv3 included in the packaging of this file. Please review the
# following information to ensure the GNU Lesser General Public License
# requirements will be met: https://www.gnu.org/licenses/lgpl.html and
# http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
#
# As a special exception, The Qt Company gives you certain additional
# rights. These rights are described in The Qt Company LGPL Exception
# version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
#
# $QT_END_LICENSE$
#
############################################################################

# lisbusb-1.0 is needed by tqtc-boot2qt/qdb

. "$PSScriptRoot\helpers.ps1"

$archive = "C:\users\qt\downloads\libusb-1.0.21.7z"
$libusb_location = "C:\Utils\libusb-1.0"

Download https://vorboss.dl.sourceforge.net/project/libusb/libusb-1.0/libusb-1.0.21/libusb-1.0.21.7z http://ci-files01-hki.ci.local/input/libusb-1.0/libusb-1.0.21.7z $archive
Verify-Checksum $archive "37c8884a0ddca97d492b8ef3e08970ae3ba20653"

Extract-7Zip $archive $libusb_location

# Tell tqtc-boot2qt/qdb build system where to find libusb
[Environment]::SetEnvironmentVariable("LIBUSB_PATH", $libusb_location, "Machine")
