#!/bin/bash

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

# Install required packages with APT

source "${BASH_SOURCE%/*}/../common/try_catch.sh"

ExceptionAPTUpdate=100
ExceptionAPT=101
ExceptionSED=102

try
(
    echo "Disabling auto update"
    sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' /etc/apt/apt.conf.d/10periodic || throw $ExceptionSED
    echo "Running update for apt"
    sudo apt update
    echo "Installing packages"
    # Git is not needed by builds themselves, but is nice to have
    # immediately as one starts debugging
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install git || throw $ExceptionAPT
    # 7zip is a needed decompressing tool
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install p7zip || throw $ExceptionAPT
    # libssl-dev provides headers for OpenSSL
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libssl-dev || throw $ExceptionAPT
    # Needed libraries for X11 support accordingly to https://wiki.qt.io/Building_Qt_5_from_Git
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev || throw $ExceptionAPT
    # Enable linking to system dbus
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libdbus-1-dev || throw $ExceptionAPT
    # Needed libraries for WebEngine
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libudev-dev libegl1-mesa-dev libfontconfig1-dev libxss-dev || throw $ExceptionAPT
    # Common event loop handling
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libglib2.0-dev || throw $ExceptionAPT
    # MySQL support
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libmysqlclient-dev || throw $ExceptionAPT
    # PostgreSQL support
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libpq-dev || throw $ExceptionAPT
    # SQLite support
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libsqlite3-dev || throw $ExceptionAPT
    # ODBC support
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install unixodbc-dev || throw $ExceptionAPT
    # Support for FreeType font engine
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libfreetype6-dev || throw $ExceptionAPT
    # Enable the usage of system jpeg libraries
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libjpeg-dev || throw $ExceptionAPT
    # Enable support for printer driver
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libcups2-dev || throw $ExceptionAPT
    # Install libraries needed for QtMultimedia to be able to support all plugins
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev || throw $ExceptionAPT
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev || throw $ExceptionAPT
    # Support for cross-building to x86 (needed by WebEngine boot2qt builds)
    sudo DEBIAN_FRONTEND=noninteractive apt -q -y install g++-multilib || throw $ExceptionAPT
)
catch || {
    case $ex_code in
        $ExceptionAPTUpdate)
            echo "Failed to run APT update."
            exit 1;
        ;;
        $ExceptionAPT)
            echo "Failed to install package."
            exit 1;
        ;;
        $ExceptionSED)
            echo "Failed to disable auto update."
            exit 1;
        ;;
    esac
}

