# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

$credentialsFile = "$env:USERPROFILE\vcpkg_samba_credentials"

# Extract username and password from the credentials
$username = "vcpkg"
$securePassword = Get-Content -Path "$credentialsFile" -TotalCount 1 | ConvertTo-SecureString -AsPlainText -Force

# Create a PSCredential object
$credential = New-Object PSCredential -ArgumentList $username, $securePassword

# Mount the SMB share
# Check if the mount was successful
if (New-PSDrive -Persist -Scope Global -Name V -PSProvider FileSystem -Root \\vcpkg-server.ci.qt.io\vcpkg -Credential $credential)
{
    Write-Host "SMB share mounted successfully!"
} else {
    Write-Host "Failed to mount SMB share."
}
