#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

systemd_folder=/etc/systemd/system
systemd_file=vivid.service
script_folder=/home/qt/bin
script_file=vivid.sh

# Ensure that script folder exists
if [ ! -d ${script_folder} ]; then
    sudo mkdir ${script_folder}
    sudo chmod 750 ${script_folder}
fi

# Create script to install virtual video test driver module
sudo tee "${script_folder}/${script_file}" <<"EOF"
# load vivid
sudo modprobe vivid n_devs=2 # create two video devices

# Check result
if lsmod | grep -q vivid
then
    echo "(**) Virtual video test driver vivid installed.";
else
    echo "(EE) Failed to load vivid driver.";
    exit 1;
fi
EOF

# set permissions
sudo chmod 750 "${script_folder}/${script_file}"

# Create service file
sudo tee "${systemd_folder}/${systemd_file}" <<"EOF"
# /etc/systemd/system/vivid.service
#

[Unit]
Description=Install virtual video test driver (vivid)

[Service]
Type=oneshot
ExecStart=/bin/sh -c "/home/qt/bin/vivid.sh"

[Install]
WantedBy=multi-user.target
EOF

# Start service and output result, just for logging
sudo systemctl start vivid.service

# enable service
sudo systemctl enable vivid.service
