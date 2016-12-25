. "$PSScriptRoot\..\common\helpers.ps1"

# OpenSSL need to be configured from sources for Android build in windows 7
# Msys need to be installed to target machine
# More info and building instructions can be found from http://doc.qt.io/qt-5/opensslsupport.html

$version = "1.0.2j"
$zip = "c:\users\qt\downloads\openssl-$version.tar.gz"
$sha1 = "bdfbdb416942f666865fa48fe13c2d0e588df54f"
$destination = "C:\Utils\openssl-android-master"

Download https://www.openssl.org/source/openssl-$version.tar.gz http://ci-files01-hki.ci.local/input/openssl/openssl-$version.tar.gz $zip
Verify-Checksum $zip $sha1

C:\Utils\sevenzip\7z.exe x $zip -oC:\Utils
C:\Utils\sevenzip\7z.exe x C:\Utils\openssl-$version.tar -oC:\Utils
Remove-Item $destination -Force -Recurse
Rename-Item C:\Utils\openssl-$version $destination
Remove-Item $zip
Remove-Item C:\Utils\openssl-$version.tar

set CC=C:\utils\android-ndk-r10e\toolchains\arm-linux-androideabi-4.9\prebuilt\windows\bin\arm-linux-androideabi-gcc
set AR=C:\utils\android-ndk-r10e\toolchains\arm-linux-androideabi-4.9\prebuilt\windows\bin\arm-linux-androideabi-ar
set ANDROID_DEV=C:\utils\android-ndk-r10e\platforms\android-18\arch-arm\usr
$env:Path = $env:Path + ";C:\msys\1.0\bin"

echo "Configuring OpenSSL $version for Android..."
cd $destination
C:\msys\1.0\bin\bash.exe -c "perl Configure shared android"

# Following command is needed when using version 1.1.0. With version 1.1.0 msys is not needed.
# C:\mingw530\bin\mingw32-make.exe include\openssl\opensslconf.h
