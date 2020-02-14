#!/usr/bin/env sh

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

# Install tools for singing packages
# This script assume that OS is vanilla. Target machine dosen't have any signing certificates installed.

set -ex

cache="http://ci-files01-hki.intra.qt.io/input"
cacheSigningTools="$cache/mac/sign_tools"
targetFolder="/Users/qt"
keychains="$targetFolder/Library/Keychains"

Install() {

    url=$1
    targetFile=$2
    expectedSha1=$3

    echo "Fetching $targetFile from $url..."
    curl --retry 5 --retry-delay 10 --retry-max-time 60 "$url" -o "$targetFile"
    shasum "$targetFile" |grep "$expectedSha1"

}

# qt-license
sha1QtLicense="9d59241d16f68d914f1c7aa1dc23e05faa169e8d"
Install "$cache/semisecure/.qt-license" "$targetFolder/.qt-license" $sha1QtLicense

# Login keychain
sha1LoginKeychainPassword="aae58d00d0a1b179a09f21cfc67f9d16fb95ff36"
Install "$cacheSigningTools/login_keychain_password.txt" "$targetFolder/login_keychain_password.txt" "$sha1LoginKeychainPassword"
{ loginKeychainPassword=$(cat "$targetFolder/login_keychain_password.txt"); } 2> /dev/null
loginKeychain=$keychains/login.keychain

echo "Setting login.keychain as default keychain.."
security default-keychain -s $loginKeychain*
echo "Unlocking Login keychain with password.."
{ security unlock-keychain -p "$loginKeychainPassword" $loginKeychain*; } 2> /dev/null

echo "remove the "Lock after X minutes of inactivity" from login.keychain"
security set-keychain-settings $loginKeychain

# Apple Worldwide Developer Relations Certification Authority -> https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
sha1AppleWWDRCA="ff6797793a3cd798dc5b2abef56f73edc9f83a64"
Install "$cacheSigningTools/AppleWWDRCA.cer" "$targetFolder/AppleWWDRCA.cer" $sha1AppleWWDRCA
sudo security add-certificates -k $loginKeychain* "$targetFolder/AppleWWDRCA.cer"

# Developer ID Certification Authority -> https://www.apple.com/certificateauthority/DeveloperIDCA.cer
sha1DeveloperIDCA="3b166c3b7dc4b751c9fe2afab9135641e388e186"
Install "$cacheSigningTools/DeveloperIDCA.cer" "$targetFolder/DeveloperIDCA.cer" $sha1DeveloperIDCA
sudo security add-certificates -k $loginKeychain* "$targetFolder/DeveloperIDCA.cer"

# Create script to unlock keychain 'security unlock-keychain -p 'password' Developer_ID_TheQtCompany.keychain'
sha1UnLockKeychain="4398870e3f558ad28c80566b5f70e24dc29ea724"
unlockKeychain=$targetFolder/unlock-keychain.sh
{ Install "$cacheSigningTools/unlock-keychain.sh" "$unlockKeychain" $sha1UnLockKeychain; } 2> /dev/null
sudo chmod 755 "$unlockKeychain"

# Codesigning requirements file. The bundle identifier in the requirements file should match the identifier of the application that is signed.
shaCsreq="2c3f00b1845a0f475673fd6934ba25ea51d1f910"
csreq=$targetFolder/csreq_qt_company.txt
Install "$cacheSigningTools/csreq_qt_company.txt" "$csreq" $shaCsreq
chmod 755 "$csreq"

# iOS signing tools
devIDKeychain="Developer_ID_TheQtCompany.keychain-db"
shaDevIdKeychain="972cca1879cdaeeb6042f9879756c748a8d1eddc"
Install "$cacheSigningTools/$devIDKeychain" "$keychains/$devIDKeychain" $shaDevIdKeychain
echo "Opening $devIDKeychain.."
open "$keychains/$devIDKeychain"

sha1DeveloperIDTheQtCompanyKeychainPassword="d758e067736bbda7a91ffaec66cd38afdaf68ea6"
Install "$cacheSigningTools/Developer_ID_TheQtCompany_keychain_password.txt" "$targetFolder/Developer_ID_TheQtCompany_keychain_password.txt" "$sha1DeveloperIDTheQtCompanyKeychainPassword"
{ DeveloperIDTheQtCompanyKeychainPassword=$(cat "$targetFolder/Developer_ID_TheQtCompany_keychain_password.txt"); } 2> /dev/null

echo "Unlocking $devIDKeychain with password.."
{ security unlock-keychain -p "$DeveloperIDTheQtCompanyKeychainPassword" $keychains/Developer_ID_TheQtCompany.keychain; } 2> /dev/null
security set-keychain-settings $keychains/Developer_ID_TheQtCompany.keychain

sha1Ios="aae58d00d0a1b179a09f21cfc67f9d16fb95ff36"
{ Install "$cacheSigningTools/ios_password.txt" "$targetFolder/ios_password.txt" $sha1Ios; } 2> /dev/null
{ iosPassword=$(cat "$targetFolder/ios_password.txt"); } 2> /dev/null

iPhoneDeveloper="iosDevelopment2019CiTeam.p12"
shaIPhoneDeveloper="fa22abe1b1cc64af6585f7a61c4aba5e00220bdc"
Install "$cacheSigningTools/latest_ios_cert_2019/$iPhoneDeveloper" "$targetFolder/$iPhoneDeveloper" $shaIPhoneDeveloper
echo "Importing $iPhoneDeveloper.."
{ security import $targetFolder/$iPhoneDeveloper -k $loginKeychain* -P "$iosPassword" -T /usr/bin/codesign; } 2> /dev/null

iPhoneDistribution="iosDistribution2019CiTeam.p12"
shaIPhoneDistribution="6510119651c7aecb21d0a1dae329f2eae1e8f4e9"
Install "$cacheSigningTools/latest_ios_cert_2019/$iPhoneDistribution" "$targetFolder/$iPhoneDistribution" $shaIPhoneDistribution
echo "Importing $iPhoneDistribution.."
{ security import "$targetFolder/$iPhoneDistribution" -k $loginKeychain* -P "$iosPassword" -T /usr/bin/codesign; } 2> /dev/null

# Mobileprovision
echo "Creating directory $targetFolder/Library/MobileDevice/Provisioning Profiles.."
mkdir "$targetFolder/Library/MobileDevice"
mkdir "$targetFolder/Library/MobileDevice/Provisioning Profiles"
shaMobileprovision="477a7f3876c4333bd56a045df0d82fce795b1ebb"
Install "$cacheSigningTools/latest_ios_cert_2019/iOS_Dev_2019_citeam.mobileprovision" "$targetFolder/Library/MobileDevice/Provisioning Profiles/iOS_Dev08112017.mobileprovision" $shaMobileprovision

# Removing password files
rm -fr "$targetFolder/login_keychain_password.txt"

