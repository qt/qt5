. "$PSScriptRoot\helpers.ps1"

# This script installs Windows App SDK

$script:nugetVersion = "v6.11.0"
$script:nugetPackage = "nuget_$nugetVersion.exe"
$script:packageRoot = "C:\Utils\WindowsAppSdk\"

$script:cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\nuget\$nugetPackage"
$script:officialUrl = "https://dist.nuget.org/win-x86-commandline/$nugetVersion/nuget.exe"
$script:sdkChecksumSha1 = "5443887cfb5283da5021388d146ebb5febdc82e9"
$script:package_path = "$packageRoot\\$nugetPackage"

New-Item -ItemType Directory -Path "$packageRoot"
Download $officialUrl $cachedUrl $package_path
Verify-Checksum $package_path $sdkChecksumSha1 sha1
Write-Host "Installing Nuget"
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
