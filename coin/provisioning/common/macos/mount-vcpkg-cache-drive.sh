#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

# Avoid leaking secrets in the logs
set +x

targetDir="$HOME/vcpkg-cache"

# Specify the path to the credential file
credentialFile="$HOME/samba_credentials"
username=$(grep '^username=' "$credentialFile" | cut -d '=' -f 2)
password=$(grep '^password=' "$credentialFile" | cut -d '=' -f 2)

mkdir -p "$targetDir"

# Mount the SMB share
# Check if the mount was successful
if mount -v -t smbfs -o -N "//${username}:${password}@vcpkg-server.ci.qt.io/vcpkg" "$targetDir"
then
    echo "SMB share mounted successfully!"
else
    echo "Failed to mount SMB share."
fi

set -x
