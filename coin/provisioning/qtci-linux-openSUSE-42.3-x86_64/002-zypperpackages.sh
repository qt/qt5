#!/bin/bash
set -e

sudo zypper -nq install git
# default compiler, gcc 4.8.5
sudo zypper -nq install gcc
sudo zypper -nq install gcc-c++

sudo zypper -nq install bison
sudo zypper -nq install flex
sudo zypper -nq install gperf

sudo zypper -nq install zlib-devel
sudo zypper -nq install libudev-devel
sudo zypper -nq install glib2-devel
sudo zypper -nq install libopenssl-devel
sudo zypper -nq install freetype2-devel
sudo zypper -nq install fontconfig-devel

# EGL support
sudo zypper -nq install Mesa-libEGL-devel
sudo zypper -nq install Mesa-libGL-devel

sudo zypper -nq install libxkbcommon-devel

# Xinput2
sudo zypper -nq install libXi-devel

# system provided XCB libraries
sudo zypper -nq install xcb-util-devel
sudo zypper -nq install xcb-util-image-devel
sudo zypper -nq install xcb-util-keysyms-devel
sudo zypper -nq install xcb-util-wm-devel
sudo zypper -nq install xcb-util-renderutil-devel

# ICU
sudo zypper -nq install libicu-devel
sudo zypper -nq install libicu52_1

# qtwebengine
sudo zypper -nq install alsa-devel
sudo zypper -nq install dbus-1-devel
sudo zypper -nq install libXcomposite-devel
sudo zypper -nq install libXcursor-devel
sudo zypper -nq install libXrandr-devel
sudo zypper -nq install libXtst-devel
sudo zypper -nq install mozilla-nspr-devel
sudo zypper -nq install mozilla-nss-devel
