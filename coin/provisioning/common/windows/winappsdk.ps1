. "$PSScriptRoot\helpers.ps1"

# This script installs Windows App SDK

$nugetPackage = "nuget.exe"
$packageRoot = "C:\Utils\WindowsAppSdk\"

$cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\nuget\$nugetPackage"
$officialUrl = "https://dist.nuget.org/win-x86-commandline/v6.11.0/nuget.exe"
$sdkChecksumSha1 = "5443887cfb5283da5021388d146ebb5febdc82e9"
$package_path = "$packageRoot\\$nugetPackage"

New-Item -ItemType Directory -Path "$packageRoot"
Download $officialUrl $cachedUrl $package_path
Verify-Checksum $package_path $sdkChecksumSha1 sha1
Write-Host "Installing Nuget"
Run-Executable "$package_path" "install Microsoft.WindowsAppSDK -OutputDirectory $packageRoot"

if ([System.Environment]::Is64BitProcess) {
    $cppWinRt_path = "C:\Program Files*\Windows Kits\*\bin\*\x64\cppwinrt.exe"
} else {
    $cppWinRt_path = "C:\Program Files*\Windows Kits\*\bin\*\x86\cppwinrt.exe"
}

if (Resolve-Path -Path $cppWinRt_path) {
    $cppWinRt_path = $(Resolve-Path -Path $cppWinRt_path).Path
}
else {
    Run-Executable "$package_path" "install Microsoft.Windows.CppWinRT -OutputDirectory $packageRoot"
    $cppWinRt_path = $(Resolve-Path -Path "$packageRoot\\Microsoft.Windows.CppWinRT.*\\bin\\cppwinrt.exe").Path
}

$winAppSDK_path = $(Resolve-Path -Path "$packageRoot\Microsoft.WindowsAppSDK.*").Path
$webview2_path = $(Resolve-Path -Path "$packageRoot\Microsoft.Web.WebView*").Path

Write-Output "CppWinRT Path = $cppWinRt_path"
Write-Output "WindowsAppSdk Path = $winAppSDK_path"
Write-Output "WebView2 Path = $webview2_path"

if ([System.Environment]::Is64BitProcess) {
    Set-EnvironmentVariable "WIN_APP_SDK_ROOT_x64" "$winAppSDK_path"
    Set-EnvironmentVariable "WEBVIEW2_SDK_ROOT_x64" "$webview2_path"
    Set-EnvironmentVariable "CPP_WIN_RT_PATH_x64" "$cppWinRt_path"
} else {
    Set-EnvironmentVariable "WIN_APP_SDK_ROOT_x86" "$winAppSDK_path"
    Set-EnvironmentVariable "WEBVIEW2_SDK_ROOT_x86" "$webview2_path"
    Set-EnvironmentVariable "CPP_WIN_RT_PATH_x86" "$cppWinRt_path"
}

