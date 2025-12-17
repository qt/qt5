# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs Windows App SDK

$script:packageRoot = "C:\Utils\WindowsAppSdk\"

$script:package_path = [System.Environment]::GetEnvironmentVariable('NUGET_EXE_PATH', [System.EnvironmentVariableTarget]::Machine)

Run-Executable "$package_path" "install Microsoft.WindowsAppSDK -OutputDirectory $packageRoot"

$script:cpuarch = Get-CpuArchitecture
$script:cppWinRt_path = "C:\Program Files*\Windows Kits\*\bin\*\$cpuarch\cppwinrt.exe"

if (Resolve-Path -Path $cppWinRt_path) {
    $cppWinRt_path = $(Resolve-Path -Path $cppWinRt_path).Path
}
else {
    Run-Executable "$package_path" "install Microsoft.Windows.CppWinRT -OutputDirectory $packageRoot"
    $cppWinRt_path = $(Resolve-Path -Path "$packageRoot\\Microsoft.Windows.CppWinRT.*\\bin\\cppwinrt.exe").Path
}

$script:winAppSDK_path = $(Resolve-Path -Path "$packageRoot\Microsoft.WindowsAppSDK.*").Path
$script:webview2_path = $(Resolve-Path -Path "$packageRoot\Microsoft.Web.WebView*").Path

Write-Output "CppWinRT Path = $cppWinRt_path"
Write-Output "WindowsAppSdk Path = $winAppSDK_path"
Write-Output "WebView2 Path = $webview2_path"

Set-EnvironmentVariable "WIN_APP_SDK_ROOT_PATH" "$winAppSDK_path"
Set-EnvironmentVariable "WEBVIEW2_SDK_ROOT_PATH" "$webview2_path"
Set-EnvironmentVariable "CPP_WIN_RT_PATH_$cpuarch" "$cppWinRt_path"
