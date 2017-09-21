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
############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script installs ICU.

$version = "53_1"

if(($env:PROCESSOR_ARCHITECTURE -eq "AMD64") -or ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64")) {

   $url_official_2012 = "http://download.qt.io/development_releases/prebuilt/icu/prebuilt/msvc2012/icu_" + $version + "_msvc_2012_64_devel.7z"
   $url_cache_2012 = "\\ci-files01-hki.intra.qt.io\provisioning\windows\icu_" + $version + "_msvc_2012_64_devel.7z"
   $sha1_2012 = "8A8C371F3ED58E81BBCF58CF5F8388CEF51FA9AC"

   $url_official_2013 = "http://download.qt.io/development_releases/prebuilt/icu/prebuilt/msvc2013/icu_" + $version + "_msvc_2013_64_devel.7z"
   $url_cache_2013 = "\\ci-files01-hki.intra.qt.io/provisioning/windows/icu_" + $version + "_msvc_2013_64_devel.7z"
   $sha1_2013 = "7267CF8C5BD39C4218F2CCFE31ECA81B7644ED6F"

   $icuPackage_msvc2012_64 = "C:\Windows\Temp\icu-$version-msvc2012_64.7z"
   $icuPackage_msvc2013_64 = "C:\Windows\Temp\icu-$version-msvc2013_64.7z"

   if (!(Test-Path C:\Utils\icu_"$version"_msvc_2012_64_devel\)) {
      echo "Fetching from URL ..."
      Download $url_official_2012 $url_cache_2012 $icuPackage_msvc2012_64
      Verify-Checksum $icuPackage_msvc2012_64 $sha1_2012
      Get-ChildItem $icuPackage_msvc2012_64 | % {& "C:\Utils\sevenzip\7z.exe" "x" $_.fullname -o""C:\Utils\icu_"$version"_msvc_2012_64_devel\""}

      echo "Cleaning $icuPackage_msvc2012_64..."
      Remove-Item -Recurse -Force $icuPackage_msvc2012_64

      echo "ICU MSVC2012 = $version" >> ~\versions.txt
   }

   if (!(Test-Path C:\Utils\icu_"$version"_msvc_2013_64_devel\)) {
      echo "Fetching from URL ..."
      Download $url_official_2013 $url_cache_2013 $icuPackage_msvc2013_64
      Verify-Checksum $icuPackage_msvc2013_64 $sha1_2013
      Get-ChildItem $icuPackage_msvc2013_64 | % {& "C:\Utils\sevenzip\7z.exe" "x" $_.fullname -o""C:\Utils\icu_"$version"_msvc_2013_64_devel\""}

      echo "Cleaning $icuPackage_msvc2013_64..."
      Remove-Item -Recurse -Force $icuPackage_msvc2013_64

      echo "ICU MSVC2013 = $version" >> ~\versions.txt
   }

# FIXME: do we really want to have it per MSVC version? What about MSVC2015?
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2012", "C:\\Utils\\icu_53_1_msvc_2012_64_devel\\icu53_1", "Machine")
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2013", "C:\\Utils\\icu_53_1_msvc_2013_64_devel\\icu53_1", "Machine")

# FIXME: do we really want to use the 4.8.2 ICU build?
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_Mingw49", "C:\Utils\icu_53_1_Mingw_builds_4_8_2_posix_seh_64_devel\icu53_1", "Machine")

} else {

   $url_official_2012_32 = "http://download.qt.io/development_releases/prebuilt/icu/prebuilt/msvc2012/icu_" + $version + "_msvc_2012_32_devel.7z"
   $url_cache_2012_32 = "\\ci-files01-hki.intra.qt.io\provisioning\windows\icu_" + $version + "_msvc_2012_32_devel.7z"
   $sha1_2012_32 = "F2FF287EEB0163B015D37AE08871165FBA87BCF0"

   $url_official_2013_32 = "http://download.qt.io/development_releases/prebuilt/icu/prebuilt/msvc2013/icu_" + $version + "_msvc_2013_32_devel.7z"
   $url_cache_2013_32 = "\\ci-files01-hki.intra.qt.io/provisioning/windows/icu_" + $version + "_msvc_2013_32_devel.7z"
   $sha1_2013_32 = "D745A5F0F6A3817AE989501A01A5A0BA53FDB800"

   $icuPackage_msvc2012_32 = "C:\Windows\Temp\icu-$version-msvc2012_32.7z"
   $icuPackage_msvc2013_32 = "C:\Windows\Temp\icu-$version-msvc2013_32.7z"

   if (!(Test-Path C:\Utils\icu_"$version"_msvc_2012_32_devel\)) {
      echo "Fetching from URL ..."
      Download $url_official_2012_32 $url_cache_2012_32 $icuPackage_msvc2012_32
      Verify-Checksum $icuPackage_msvc2012_32 $sha1_2012_32
      Get-ChildItem $icuPackage_msvc2012_32 | % {& "C:\Utils\sevenzip\7z.exe" "x" $_.fullname -o""C:\Utils\icu_"$version"_msvc_2012_32_devel\""}

      echo "Cleaning $icuPackage_msvc2012_32..."
      Remove-Item -Recurse -Force $icuPackage_msvc2012_32

      echo "ICU MSVC2012 = $version" >> ~\versions.txt
   }

   if (!(Test-Path C:\Utils\icu_"$version"_msvc_2013_32_devel\)) {
      echo "Fetching from URL ..."
      Download $url_official_2013_32 $url_cache_2013_32 $icuPackage_msvc2013_32
      Verify-Checksum $icuPackage_msvc2013_32 $sha1_2013_32
      Get-ChildItem $icuPackage_msvc2013_32 | % {& "C:\Utils\sevenzip\7z.exe" "x" $_.fullname -o""C:\Utils\icu_"$version"_msvc_2013_32_devel\""}

      echo "Cleaning $icuPackage_msvc2013_32..."
      Remove-Item -Recurse -Force $icuPackage_msvc2013_32

      echo "ICU MSVC2013 = $version" >> ~\versions.txt
   }

# FIXME: do we really want to have it per MSVC version? What about MSVC2015?
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2012", "C:\\Utils\\icu_53_1_msvc_2012_32_devel\\icu53_1", "Machine")
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2013", "C:\\Utils\\icu_53_1_msvc_2013_32_devel\\icu53_1", "Machine")

}
