#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo zypper -nq install elfutils binutils

sudo zypper addrepo --no-gpgcheck http://repo-clones.ci.qt.io/repos/opensuse/repositories/devel/gcc/SLE-15/devel:gcc.repo
sudo zypper refresh
sudo zypper -nq install --force-resolution gcc11 gcc11-c++

# Make sure needed ca-certificates are available
sudo zypper -nq install ca-certificates

sudo /usr/sbin/update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 1 \
                                     --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
                                     --slave /usr/bin/cc cc /usr/bin/gcc-11 \
                                     --slave /usr/bin/c++ c++ /usr/bin/g++-11

sudo zypper -nq install git ninja make patch wget tar

sudo zypper -nq install bison flex gperf \
        zlib-devel \
        libudev-devel \
        glib2-devel \
        freetype2-devel \
        fontconfig-devel \
        sqlite3-devel \
        libxkbcommon-devel \
        libxkbcommon-x11-devel

sudo zypper -nq install cmake

sudo zypper -nq install p7zip

# EGL support
sudo zypper -nq install Mesa-libEGL-devel Mesa-libGL-devel

# ICU
sudo zypper -nq install libicu-devel libicu-suse65_1

# gtk3 style for QtGui/QStyle
sudo zypper -nq install gtk3-devel

# Xinput2
sudo zypper addrepo --no-gpgcheck http://repo-clones.ci.qt.io/repos/download.postgresql.org/pub/repos/zypp/14/suse/pgdg-sles-15-pg14.repo
# Leaving postgresql14-devel out as dependency with clang15-devel doesn't yet have provider
sudo zypper -nq install libXi-devel postgresql14 mysql-devel mysql mysql-server

# system provided XCB libraries
sudo zypper -nq install xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel \
         xcb-util-wm-devel xcb-util-renderutil-devel

# temporary solution for libxcb-cursor0 xcb-util-cursor-devel
sudo zypper addrepo --no-gpgcheck http://repo-clones.ci.qt.io/repos/opensuse/repositories/home/liangqi_qt/branches/SUSE/SLE-15-SP6/GA/pool-leap-15.6/home:liangqi_qt:branches:SUSE:SLE-15-SP6:GA.repo
sudo zypper refresh
sudo zypper -nq install --force-resolution libxcb-cursor0 xcb-util-cursor-devel

# qtwebengine
sudo zypper -nq install alsa-devel dbus-1-devel libxkbfile-devel libdrm-devel \
         libXcomposite-devel libXcursor-devel libXrandr-devel libXtst-devel \
         mozilla-nspr-devel mozilla-nss-devel glproto-devel libxshmfence-devel \
         vulkan-devel

# qtwebkit
sudo zypper -nq install libxml2-devel libxslt-devel

# yasm (for ffmpeg in multimedia)
sudo zypper -nq install yasm

# GStreamer (qtwebkit and qtmultimedia), pulseaudio (qtmultimedia)
sudo zypper -nq install gstreamer-devel gstreamer-plugins-base-devel libpulse-devel

# cups
sudo zypper -nq install cups-devel

# speech-dispatcher
sudo zypper -nq install libspeechd-devel
#sudo sed -i 's:includedir=/usr/include:includedir=/usr/include/speech-dispatcher:' /usr/lib64/pkgconfig/speech-dispatcher.pc

# ODBC support
sudo zypper -nq install unixODBC-devel unixODBC

# sqlite support
sudo zypper -nq install sqlite3 sqlite3-devel

# Java - needed by RTA jenkins
sudo zypper -nq install java java-17-openjdk-devel

# open-vm-tools requires update. Version in tier1 is broken and causes segfault on boot.
sudo zypper -nq update open-vm-tools

# Tools to build Git
sudo zypper -nq install autoconf libcurl-devel libexpat-devel

# zip, needed for vcpkg caching
sudo zypper -nq install zip

# Nodejs - required by QtWebengine
# Skip this as no provider yet, use commonly installed nodejs 18.16.0 version as it's available
#sudo zypper -nq install nodejs18

# OpenSSL 3
sudo zypper -nq install openssl-3

# cifs-utils, for mounting smb drive
sudo zypper -nq install cifs-utils

# For Firebird in RTA
sudo zypper -nq install libtommath-devel

# For tst_license.pl with all the machines generating SBOM
sudo zypper -nq install perl-JSON

gccVersion="$(gcc --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "GCC = $gccVersion" >> versions.txt

glibcVersion="$(ldd --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "glibc = $glibcVersion" >> versions.txt

OpenSSLVersion="$(openssl version |cut -b 9-14)"
echo "System's OpenSSL = $OpenSSLVersion" >> ~/versions.txt
