#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.

set -ex

# Curl is pre-installed but the original version is buggy.
# This line here is to update it.
sudo zypper -nq install curl

sudo zypper -nq install git gcc13 gcc15-c++ ninja
sudo /usr/sbin/update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 1 \
                                     --slave /usr/bin/g++ g++ /usr/bin/g++-15 \
                                     --slave /usr/bin/cc cc /usr/bin/gcc-15 \
                                     --slave /usr/bin/c++ c++ /usr/bin/g++-15

# Make sure needed ca-certificates are available
sudo zypper -nq install ca-certificates

sudo zypper -nq install bison flex gperf libgio-2_0-0=2.84.4\
        zlib-devel \
        systemd-devel \
        glib2-devel \
        libopenssl-3-devel \
        freetype2-devel \
        fontconfig-devel \
        sqlite3-devel \
        libxkbcommon-devel \
        libxkbcommon-x11-devel \
        pcre2-devel libpng16-devel

# EGL support
sudo zypper -nq install Mesa-libEGL-devel Mesa-libGL-devel


# Xinput2
sudo zypper -nq install libXi-devel

# system provided XCB libraries
sudo zypper -nq install xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel \
         xcb-util-wm-devel xcb-util-renderutil-devel xcb-util-cursor-devel

# ICU
sudo zypper -nq install libicu-devel

# qtwebengine
sudo zypper -nq install alsa-devel dbus-1-devel libxkbfile-devel \
         libXcomposite-devel libXcursor-devel libXrandr-devel libXtst-devel \
         mozilla-nspr-devel mozilla-nss-devel glproto-devel nodejs \
         libxshmfence-devel libXdamage-devel \
         'cargo<1.94' rust-bindgen

# qtwebkit
sudo zypper -nq install libxml2-devel libxslt-devel

# yasm (for ffmpeg in multimedia)
sudo zypper -nq install yasm

# GStreamer (qtwebkit and qtmultimedia), pulseaudio (qtmultimedia)
sudo zypper -nq install gstreamer-devel gstreamer-plugins-base-devel libpulse-devel pipewire-devel # gstreamer-plugin-openh264 not available

# cups
sudo zypper -nq install cups-devel

#speech-dispatcher
sudo zypper -nq install libspeechd-devel

# make
sudo zypper -nq install make

# Tools to build Git
sudo zypper -nq install autoconf libcurl-devel libexpat-devel

# zip, needed for vcpkg caching
sudo zypper -nq install zip

# OpenSSL 3
sudo zypper -nq install openssl-3

# Valgrind (Needed for testlib selftests)
sudo zypper -nq install valgrind-devel

# cifs-utils, for mounting smb drive
sudo zypper -nq install cifs-utils

# For Firebird in RTA
sudo zypper -nq install libtommath-devel

# Java
sudo zypper -nq install java-21-openjdk-devel-21.0.9.0-160000.1.1

# For tst_license.pl with all the machines generating SBOM
sudo zypper -nq install perl-JSON

# Keep zoneinfo up-to-date (COIN-1282)
sudo zypper -nq install timezone

gccVersion="$(gcc --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "GCC = $gccVersion" >> versions.txt

glibcVersion="$(ldd --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "glibc = $glibcVersion" >> versions.txt

OpenSSLVersion="$(openssl version |cut -b 9-14)"
echo "System's OpenSSL = $OpenSSLVersion" >> ~/versions.txt
