#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

targetDir="$HOME/vcpkg-cache"

# Specify the path to the credential file
credentialsFile="$HOME/samba_credentials"

sudo mkdir -p "$targetDir"

# Mount the SMB share
# Check if the mount was successful
if sudo mount -t cifs //vcpkg-server.ci.qt.io/vcpkg "$targetDir" -o credentials="$credentialsFile",uid="$(id -u)",gid="$(id -g)"
then
    echo "SMB share mounted successfully!"
else
    echo "Failed to mount SMB share."
fi
