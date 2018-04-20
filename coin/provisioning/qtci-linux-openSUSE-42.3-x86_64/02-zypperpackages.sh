#!/usr/bin/env bash

set -ex

sudo zypper -nq install git
sudo zypper -nq install gcc7
sudo zypper -nq install gcc7-c++
sudo /usr/sbin/update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 1 \
                                     --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
                                     --slave /usr/bin/cc cc /usr/bin/gcc-7 \
                                     --slave /usr/bin/c++ c++ /usr/bin/g++-7

sudo zypper -nq install bison
sudo zypper -nq install flex
sudo zypper -nq install gperf

sudo zypper -nq install zlib-devel
sudo zypper -nq install libudev-devel
sudo zypper -nq install glib2-devel
sudo zypper -nq install libopenssl-devel
sudo zypper -nq install freetype2-devel
sudo zypper -nq install fontconfig-devel
sudo zypper -nq install sqlite3-devel

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

# qtwebkit
sudo zypper -nq install libxml2-devel
sudo zypper -nq install libxslt-devel

# GStreamer (qtwebkit and qtmultimedia)
sudo zypper -nq install gstreamer-devel
sudo zypper -nq install gstreamer-plugins-base-devel

# pulseaudio (qtmultimedia)
sudo zypper -nq install libpulse-devel

# cups
sudo zypper -nq install cups-devel
