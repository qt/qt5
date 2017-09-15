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
. "$PSScriptRoot\..\..\provisioning\common\helpers.ps1"

# Install Visual Studio $version with $update_version
# Original download page: https://www.visualstudio.com/en-us/news/releasenotes/vs2015-update3-vs
$version = "2015"
$update_version = "3"

# Only way to install specific Visual studio release is to use feed.xml.
# Visual Studio $version setup will use the feed.xml that was available when $update_version released -> 'https://msdn.microsoft.com/en-us/library/mt653628.aspx'
# These parameters will install Visual Studio Enterprise Update $update_version (the original Update $update_version without any further Update $update_version-era updates)
$parameters = "/OverrideFeedURI http://download.microsoft.com/download/6/B/B/6BBD3561-D764-4F39-AB8E-05356A122545/20160628.2/enu/feed.xml"

$msvc_web_installer = "vs" + $version + "_" + $update_version
$package = "C:\Windows\temp\$msvc_web_installer.exe"
$url_cache = "http://ci-files01-hki.intra.qt.io/input/windows/$msvc_web_installer.exe"
$url_official = "https://go.microsoft.com/fwlink/?LinkId=691129"
$sha1 = "68abf90424aff604a04d6c61fb52adcd2cab2266"

echo "Fetching Visual Studio $version update $update_version..."
Download $url_official $url_cache $package
Verify-Checksum $package $sha1
echo "Installing Visual studio $version update $update_version..."
cmd /c "$package $parameters /norestart /Quiet"
remove-item $package

echo "Visual Studio = $version update $update_version" >> ~\versions.txt
