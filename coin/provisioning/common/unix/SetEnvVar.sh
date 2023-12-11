#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# A helper script used for setting environment variables on Unix systems

set -ex

function SetEnvVar {
    name=$1
    path=$2

    echo "Setting environment variable $name to $path."

    if uname -a |grep -q -E "Ubuntu|Debian"; then
        if lsb_release -a |grep "Ubuntu 22.04"; then
            echo "export $name=$path" >> ~/.bashrc
            echo "export $name=$path" >> ~/.bash_profile
        else
            echo "export $name=$path" >> ~/.profile
        fi
    else
        echo "export $name=$path" >> ~/.bashrc
        echo "export $name=$path" >> ~/.zshrc
        echo "export $name=$path" >> ~/.zshenv
        echo "export $name=$path" >> ~/.zprofile
    fi
}
