# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script will install Azure singtool using Dotnet SDK
$dotnet = "C:\Program Files\dotnet\dotnet.exe"

$version = "5.0.0"
Run-Executable "$dotnet" "tool install --global AzureSignTool --version $version"

