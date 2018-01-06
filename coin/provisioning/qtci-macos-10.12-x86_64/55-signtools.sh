#!/usr/bin/env sh

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
loginKeychainPassword=$(<"$targetFolder/login_keychain_password.txt")
loginKeychain=$keychains/login.keychain

echo "Setting login.keychain as default keychain.."
security default-keychain -s $loginKeychain*
echo "Unlocking Login keychain with password.."
security unlock-keychain -p "$loginKeychainPassword" $loginKeychain*

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
Install "$cacheSigningTools/unlock-keychain.sh" "$unlockKeychain" $sha1UnLockKeychain
sudo chmod 755 "$unlockKeychain"

# Codesigning requirements file. The bundle identifier in the requirements file should match the identifier of the application that is signed.
shaCsreq="2c3f00b1845a0f475673fd6934ba25ea51d1f910"
csreq=$targetFolder/csreq_qt_company.txt
Install "$cacheSigningTools/csreq_qt_company.txt" "$csreq" $shaCsreq
chmod 755 "$csreq"

# iOS signing tools
devIDKeychain="Developer_ID_TheQtCompany.keychain"
shaDevIdKeychain="0420a129c17725a97afd6fdafeb9cddfb80a65ca"
Install "$cacheSigningTools/$devIDKeychain" "$keychains/$devIDKeychain" $shaDevIdKeychain
echo "Opening $devIDKeychain.."
open "$keychains/$devIDKeychain"

sha1DeveloperIDTheQtCompanyKeychainPassword="d758e067736bbda7a91ffaec66cd38afdaf68ea6"
Install "$cacheSigningTools/Developer_ID_TheQtCompany_keychain_password.txt" "$targetFolder/Developer_ID_TheQtCompany_keychain_password.txt" "$sha1DeveloperIDTheQtCompanyKeychainPassword"
DeveloperIDTheQtCompanyKeychainPassword=$(<"$targetFolder/Developer_ID_TheQtCompany_keychain_password.txt")

echo "Unlocking $devIDKeychain with password.."
security unlock-keychain -p "$DeveloperIDTheQtCompanyKeychainPassword" $keychains/Developer_ID_TheQtCompany.keychain
security set-keychain-settings $keychains/Developer_ID_TheQtCompany.keychain

sha1Ios="aae58d00d0a1b179a09f21cfc67f9d16fb95ff36"
Install "$cacheSigningTools/ios_password.txt" "$targetFolder/ios_password.txt" $sha1Ios
iosPassword=$(<"$targetFolder/ios_password.txt")

iPhoneDeveloper="iosdevelopment.p12"
shaIPhoneDeveloper="f48f6827e8d0ccdc764cb987e401b9a6f7d3f10c"
Install "$cacheSigningTools/latest_ios_cert/$iPhoneDeveloper" "$targetFolder/$iPhoneDeveloper" $shaIPhoneDeveloper
echo "Importing $iPhoneDeveloper.."
security import $targetFolder/$iPhoneDeveloper -k $loginKeychain* -P $iosPassword -T /usr/bin/codesign

iPhoneDistribution="iosdistribution.p12"
shaIPhoneDistribution="64b1174fc3ce0eca044fbc9fa144f6a2d4330171"
Install "$cacheSigningTools/latest_ios_cert/$iPhoneDistribution" "$targetFolder/$iPhoneDistribution" $shaIPhoneDistribution
echo "Importing $iPhoneDistribution.."
security import "$targetFolder/$iPhoneDistribution" -k $loginKeychain* -P $iosPassword -T /usr/bin/codesign

# Mobileprovision
echo "Creating directory $targetFolder/Library/MobileDevice/Provisioning Profiles.."
mkdir "$targetFolder/Library/MobileDevice"
mkdir "$targetFolder/Library/MobileDevice/Provisioning Profiles"
shaMobileprovision="88c67c95a6f59e6463a00da0b5021f581db624bf"
Install "$cacheSigningTools/latest_ios_cert/iOS_Dev08112017.mobileprovision" "$targetFolder/Library/MobileDevice/Provisioning Profiles/iOS_Dev08112017.mobileprovision" $shaMobileprovision

# Removing password files
rm -fr "$targetFolder/login_keychain_password.txt"

