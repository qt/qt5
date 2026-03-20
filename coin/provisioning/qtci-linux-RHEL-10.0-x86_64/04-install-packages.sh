#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Remove update notifications and packagekit running in the background
sudo yum -y remove PackageKit gnome-software

# CI: All platforms should have up-to-date packages when new provision is made
echo "Quick fix: Temporarily skip RHEL 10.0 updates due to cockpit update fail (QTQAINFRA-7773)"
#sudo yum -y update

installPackages=()
# Make sure needed ca-certificates are available
installPackages+=(ca-certificates)
installPackages+=(git)
installPackages+=(zlib-devel)
installPackages+=(glib2-devel)
installPackages+=(openssl-devel)
installPackages+=(freetype-devel)
installPackages+=(fontconfig-devel)
installPackages+=(curl-devel)
installPackages+=(expat-devel)
installPackages+=(gettext-devel)
installPackages+=(perl-devel)
# Required by some old pkg perl script, FindBin.pm was moved to new package in perl 5.32
installPackages+=(perl-FindBin)
installPackages+=(dh-autoreconf)
# cmake build
installPackages+=(ninja-build)
installPackages+=(pcre2-devel)
installPackages+=(double-conversion-devel)
installPackages+=(zstd)
installPackages+=(libzstd-devel)
# EGL support
installPackages+=(mesa-libEGL)

installPackages+=(libxkbfile-devel)
# Xinput2
installPackages+=(libXi-devel)
installPackages+=(mariadb-server)
installPackages+=(mariadb)
installPackages+=(mariadb-devel)
installPackages+=(postgresql-devel)
installPackages+=(cups-devel)
installPackages+=(dbus-devel)
# gstreamer 1 for QtMultimedia
# Note! gstreamer1-plugins-bad-free needs to be upgraded or it will conflicts with gstreamer1-plugins-base-devel
installPackages+=(gstreamer1-plugins-bad-free)
installPackages+=(gstreamer1-devel)
installPackages+=(gstreamer1-plugins-base-devel)
# Not available for RHEL 10.0
#installPackages+=(gstreamer1-plugin-openh264)
# pipewire for QtMultimedia
installPackages+=(pipewire-devel)
# yasm for QtMultimedia
installPackages+=(yasm)
# gtk3 style for QtGui/QStyle
installPackages+=(gtk3-devel)
# libusb1 for tqtc-boot2qt/qdb
installPackages+=(libusbx-devel)
# speech-dispatcher-devel / flite-devel for QtSpeech
installPackages+=(speech-dispatcher-devel)
installPackages+=(flite-devel)
# Python 2 devel and pip. python-pip requires the EPEL repository to be added
# Python 2 no longer supported
# installPackages+=(python2-devel python2-pip)
# Python 3 with python-devel, pip and virtualenv
installPackages+=(python3)
installPackages+=(python3-devel)
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
installPackages+=(libstdc++-static)
installPackages+=(libatomic)
# For Android builds
#installPackages+=(java-21-openjdk-devel.21.0.9.0.10-1.el10)
installPackages+=(java-21-openjdk-devel)
# For receiving shasum
installPackages+=(perl-Digest-SHA)
# INTEGRITY requirements
# Not available for RHEL 10.0
#installPackages+=(glibc.i686)
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
# installPackages+=(mesa-libwayland-egl)
# installPackages+=(mesa-libwayland-egl-devel)
installPackages+=(libwayland-egl)
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
installPackages+=(xcb-util-devel)
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
# RHEL 10.0 has newer toolset
#installPackages+=(gcc-toolset-12)
# Open source VMware Tools
installPackages+=(open-vm-tools)
# nfs-utils is needed to make mount work with ci-files01
installPackages+=(nfs-utils)
# cifs-utils, for mounting smb drive
installPackages+=(keyutils)
installPackages+=(cifs-utils)
# zip, needed for vcpkg caching
installPackages+=(zip)
# OpenSSL requirement, built by vcpkg
installPackages+=(perl-IPC-Cmd)
# password management support for Qt Creator
installPackages+=(libsecret-devel)
# For Firebird in RTA
installPackages+=(libtommath-devel)
# For tst_license.pl with all the machines generating SBOM
installPackages+=(perl-JSON)
installPackages+=(perl-Test-Simple) # To install Test::More module for SBOM
# For qtgrpc build
installPackages+=(zlib-static)
# Keep zoneinfo up-to-date (COIN-1282)
installPackages+=(tzdata)

sudo yum -y install "${installPackages[@]}"

sudo dnf install nodejs-22.19.0-2.el10_0 -y
# Required by QtCore
sudo dnf install 'perl(English)' -y

# We shouldn't use yum to install virtualenv. The one found from package repo is not
# working, but we can use installed pip
sudo pip3 install --upgrade pip
# Configure pip
sudo pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
sudo pip config --user set global.extra-index-url https://pypi.org/simple/

# Create SBOM virtual env compatible with RHEL 10.0 Python 3.12
mkdir "/home/qt/sbom/"
python3 -m venv /home/qt/sbom/venv
/home/qt/sbom/venv/bin/pip install wheel
/home/qt/sbom/venv/bin/pip install -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

# Provisioning during installation says:
# 'The script sbom2doc is installed in '/usr/local/bin' which is not on PATH.'
# hence the explicit assignment to SBOM_PYTHON_APPS_PATH.
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/home/qt/sbom/venv/bin"

# Set SBOM_PYTHON_INTERP_PATH to Python3 instance which was used to install SBOM packages from requirements
SetEnvVar "SBOM_PYTHON_INTERP_PATH" "/home/qt/sbom/venv/bin"

# Make FindPython3.cmake to find python3
sudo ln -s /usr/bin/python3 /usr/local/bin/python3

gccVersion="$(gcc --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "GCC = $gccVersion" >> versions.txt

glibcVersion="$(ldd --version |grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' |head -n 1)"
echo "glibc = $glibcVersion" >> versions.txt

OpenSSLVersion="$(openssl version |cut -b 9-14)"
echo "System's OpenSSL = $OpenSSLVersion" >> ~/versions.txt

# List all available updates
sudo yum -y list updates
