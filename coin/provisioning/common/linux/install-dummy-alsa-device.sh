#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

systemd_folder=/etc/systemd/system
systemd_file=dummysound.service
script_folder=/home/qt/bin
script_file=dummy_sound.sh

# Ensure that script folder exists
if [ ! -d ${script_folder} ]; then
    sudo mkdir ${script_folder}
    sudo chmod 750 ${script_folder}
fi


# Create script to install dummy sound driver,
# in case no other sound driver is installed.
sudo tee "${script_folder}/${script_file}" <<"EOF"
# Check for existing sound driver
if lsmod | grep -q -i snd-dummy
then
    echo "(**) Dummy sound driver already loaded. Nothing to do.";
    exit 0;
fi

# load dummy sound module
sudo modprobe snd-dummy

# Check result
if lsmod | grep -q snd_dummy
then
    echo "(**) Dummy sound driver loaded.";
else
    echo "(EE) Failed to load dummy sound driver.";
    exit 1;
fi
EOF

# set permissions
sudo chmod 750 "${script_folder}/${script_file}"

# Create service file
sudo tee "${systemd_folder}/${systemd_file}" <<"EOF"
# /etc/systemd/system/dummysound.service
#

[Unit]
Description=Install dummy sound driver

[Service]
Type=oneshot
ExecStart=/bin/sh -c "/home/qt/bin/dummy_sound.sh"

[Install]
WantedBy=multi-user.target
EOF

# Start servive and output result, just for logging
sudo systemctl start dummysound.service
# status commented out, returns 3 on VM.
# sudo systemctl status dummysound.service

# enable service
sudo systemctl enable dummysound.service
