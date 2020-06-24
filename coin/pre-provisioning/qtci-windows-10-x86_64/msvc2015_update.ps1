#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# Visual Studio $version was installed manually using $installer.
$version = "2015 update 3"
$version_number ="14.0.25420.1"
$installer = "en_visual_studio_professional_2015_with_update_3_x86_x64_web_installer_8922978.exe"

# default plus following components were selected:
# * Visual C++
#   - Common Tools for Visual C++ 2015
# * Universal Windows App Development Tools
#   - Tools (1.4.1) and Windows SDK (10.0.14393)
#   - Windows 10 SDK (10.0.10586)
#   - Windows 10 SDK (10.0.10240)
# * Common Tools
#   -Visual Studio Extensibility Tools Update 3

# NOTE! Windows SDK 10.0.14393 installation failed through visual studio installer so it was installed using $sdk_installer
$sdk_installer = "http://ci-files01-hki.intra.qt.io/input/windows/sdksetup.exe"

echo "Visual Studio = $version version $version_number" >> ~\versions.txt
