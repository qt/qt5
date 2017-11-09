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
    sudo apt-get update
    echo "Installing packages"
    # Git is not needed by builds themselves, but is nice to have
    # immediately as one starts debugging
    yes | sudo aptdcon --hide-terminal --install git || throw $ExceptionAPT
    # 7zip is a needed decompressing tool
    yes | sudo aptdcon --hide-terminal --install p7zip || throw $ExceptionAPT
    # libssl-dev provides headers for OpenSSL
    yes | sudo aptdcon --hide-terminal --install libssl-dev || throw $ExceptionAPT
    # Needed libraries for X11 support accordingly to https://wiki.qt.io/Building_Qt_5_from_Git
    yes | sudo aptdcon --hide-terminal --install "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev || throw $ExceptionAPT
    # Enable linking to system dbus
    yes | sudo aptdcon --hide-terminal --install libdbus-1-dev || throw $ExceptionAPT
    # Needed libraries for WebEngine
    yes | sudo aptdcon --hide-terminal --install libudev-dev libegl1-mesa-dev libfontconfig1-dev libxss-dev || throw $ExceptionAPT
    # Common event loop handling
    yes | sudo aptdcon --hide-terminal --install libglib2.0-dev || throw $ExceptionAPT
    # MySQL support
    yes | sudo aptdcon --hide-terminal --install libmysqlclient-dev || throw $ExceptionAPT
    # PostgreSQL support
    yes | sudo aptdcon --hide-terminal --install libpq-dev || throw $ExceptionAPT
    # SQLite support
    yes | sudo aptdcon --hide-terminal --install libsqlite3-dev || throw $ExceptionAPT
    # ODBC support
    yes | sudo aptdcon --hide-terminal --install unixodbc-dev || throw $ExceptionAPT
    # Support for FreeType font engine
    yes | sudo aptdcon --hide-terminal --install libfreetype6-dev || throw $ExceptionAPT
    # Enable the usage of system jpeg libraries
    yes | sudo aptdcon --hide-terminal --install libjpeg-dev || throw $ExceptionAPT
    # Enable support for printer driver
    yes | sudo aptdcon --hide-terminal --install libcups2-dev || throw $ExceptionAPT
    # Install libraries needed for QtMultimedia to be able to support all plugins
    yes | sudo aptdcon --hide-terminal --install libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev || throw $ExceptionAPT
    yes | sudo aptdcon --hide-terminal --install libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev || throw $ExceptionAPT
    # Support for cross-building to x86 (needed by WebEngine boot2qt builds)
    yes | sudo aptdcon --hide-terminal --install g++-multilib || throw $ExceptionAPT
    # python3 development package
    yes | sudo aptdcon --hide-terminal --install python3-dev python3-pip python3-virtualenv || throw $ExceptionAPT
    # Automates interactive applications (Needed by RTA to automate configure testing)
    yes | sudo aptdcon --hide-terminal --install expect || throw $ExceptionAPT
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
