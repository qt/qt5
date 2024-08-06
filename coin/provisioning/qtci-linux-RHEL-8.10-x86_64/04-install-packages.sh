#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Remove update notifications and packagekit running in the background
sudo yum -y remove PackageKit gnome-software

# CI: All platforms should have up-to-date packages when new provision is made
sudo yum -y update

installPackages=()
installPackages+=(git)
installPackages+=(zlib-devel)
installPackages+=(glib2-devel)
installPackages+=(openssl3)
installPackages+=(openssl3-devel)
installPackages+=(freetype-devel)
installPackages+=(fontconfig-devel)
installPackages+=(curl-devel)
installPackages+=(expat-devel)
installPackages+=(gettext-devel)
installPackages+=(perl-devel)
installPackages+=(dh-autoreconf)
# cmake build
installPackages+=(ninja-build)
installPackages+=(pcre2-devel)
installPackages+=(double-conversion-devel)
installPackages+=(zstd)
installPackages+=(libzstd-devel)
# update kernel
installPackages+=(kernel)
installPackages+=(kernel-tools)
installPackages+=(kernel-devel)
installPackages+=(kernel-core)
installPackages+=(kernel-modules)
installPackages+=(kernel-headers)
# EGL support
# mesa-libraries need to use older version than 22.1.5-2 which cause Xorg to crash
installPackages+=(mesa-libEGL-devel-21.3.4-1.el8)
installPackages+=(mesa-libGL-devel-21.3.4-1.el8)
installPackages+=(mesa-dri-drivers-21.3.4-1.el8.x86_64)
installPackages+=(mesa-libgbm-21.3.4-1.el8.x86_64)
installPackages+=(mesa-vulkan-drivers-21.3.4-1.el8.x86_64)
installPackages+=(libxkbfile-devel)
# Xinput2
installPackages+=(libXi-devel)
installPackages+=(mysql-server)
installPackages+=(mysql)
installPackages+=(mysql-devel)
installPackages+=(postgresql-devel)
installPackages+=(cups-devel)
installPackages+=(dbus-devel)
# gstreamer 1 for QtMultimedia
# Note! gstreamer1-plugins-bad-free needs to be upgraded or it will conflicts with gstreamer1-plugins-base-devel
installPackages+=(gstreamer1-plugins-bad-free)
installPackages+=(gstreamer1-devel)
installPackages+=(gstreamer1-plugins-base-devel)
# pipewire for QtMultimedia
installPackages+=(pipewire-devel)
# for QtMultimedia, ffmpeg
installPackages+=(yasm)
installPackages+=(libva-devel)
# gtk3 style for QtGui/QStyle
installPackages+=(gtk3-devel)
# libusb1 for tqtc-boot2qt/qdb
installPackages+=(libusbx-devel)
# speech-dispatcher-devel for QtSpeech, otherwise it has no backend on Linux
installPackages+=(speech-dispatcher-devel)
# Python for pyside
installPackages+=(python3.11)
installPackages+=(python3.11-pip)
installPackages+=(python3.11-devel)
# WebEngine
installPackages+=(bison)
installPackages+=(flex)
installPackages+=(gperftools-libs)
installPackages+=(gperf)
installPackages+=(alsa-lib-devel)
installPackages+=(pulseaudio-libs-devel)
installPackages+=(libdrm-devel)
installPackages+=(libva-devel)
installPackages+=(libXtst-devel)
installPackages+=(libxshmfence-devel)
installPackages+=(nspr-devel)
installPackages+=(nss-devel)
installPackages+=(python3-html5lib)
installPackages+=(libatomic)
installPackages+=(mesa-libgbm-devel-21.3.4-1.el8.x86_64)
# For Android builds
installPackages+=(java-17-openjdk-devel-17.0.9.0.9)
# For receiving shasum
installPackages+=(perl-Digest-SHA)
# INTEGRITY requirements
installPackages+=(glibc.i686)
# Enable Qt Bluetooth
installPackages+=(bluez-libs-devel)
# QtNfc
installPackages+=(pcsc-lite-devel)
# QtWebKit
installPackages+=(libxml2-devel)
installPackages+=(libxslt-devel)
# For building Wayland from source
installPackages+=(libffi-devel)
# QtWayland
#installPackages+=(mesa-libwayland-egl)
#installPackages+=(mesa-libwayland-egl-devel)
installPackages+=(libwayland-client)
installPackages+=(libwayland-cursor)
installPackages+=(libwayland-server)
# Jenkins
installPackages+=(chrpath)
# libxkbcommon
installPackages+=(libxkbcommon-devel)
installPackages+=(libxkbcommon-x11-devel)
# xcb-util-* libraries
installPackages+=(xcb-util)
installPackages+=(xcb-util-image-devel)
installPackages+=(xcb-util-keysyms-devel)
installPackages+=(xcb-util-wm-devel)
installPackages+=(xcb-util-renderutil-devel)
installPackages+=(xcb-util-cursor)
installPackages+=(xcb-util-cursor-devel)

# ODBC support
installPackages+=(unixODBC-devel)
installPackages+=(unixODBC)
# Vulkan support
installPackages+=(vulkan-devel)
installPackages+=(vulkan-tools)
# Conan: For Python build
installPackages+=(xz-devel)
installPackages+=(zlib-devel)
installPackages+=(libffi-devel)
installPackages+=(libsqlite3x-devel)
# Build.pl
installPackages+=(perl-Data-Dumper)
# In RedHat these come with Devtoolset
installPackages+=(gcc)
installPackages+=(gcc-c++)
installPackages+=(make)
# Open source VMware Tools
installPackages+=(open-vm-tools)
# cifs-utils, for mounting smb drive
installPackages+=(keyutils)
installPackages+=(cifs-utils)
# used for reading vcpkg packages version, from vcpkg.json
installPackages+=(jq)
# zip, needed for vcpkg caching
installPackages+=(zip)
# OpenSSL requirement, built by vcpkg
installPackages+=(perl-IPC-Cmd)
# password management support for Qt Creator
installPackages+=(libsecret-devel)

sudo yum -y install "${installPackages[@]}"

sudo dnf -y module install nodejs:16

# We shouldn't use yum to install virtualenv. The one found from package repo is not
# working, but we can use installed pip
sudo pip3 install --upgrade pip
# Configure pip
sudo pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
sudo pip config --user set global.extra-index-url https://pypi.org/simple/

sudo pip3 install virtualenv wheel
sudo python3.11 -m pip install virtualenv wheel
sudo python3.11 -m pip install -r "${BASH_SOURCE%/*}/../common/shared/sbom_requirements.txt"

sudo /usr/bin/pip3 install wheel
sudo /usr/bin/pip3 install dataclasses

OpenSSLVersion="$(openssl3 version |cut -b 9-14)"
echo "System's OpenSSL = $OpenSSLVersion" >> ~/versions.txt

# List all available updates
sudo yum -y list updates
