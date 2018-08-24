function Install-VCLibsDebug
{
    Param (
        [string]$Arch
    )

    $installedPackage = Get-AppxPackage Microsoft.VCLibs.140.00.Debug | Where-Object {$_.Architecture -eq $Arch}
    if ($installedPackage) {
        Write-Host "Debug VCLibs already installed for $Arch."
        return
    }

    Add-AppxPackage "C:\Program Files (x86)\Microsoft SDKs\Windows Kits\10\ExtensionSDKs\Microsoft.VCLibs\14.0\Appx\Debug\$Arch\Microsoft.VCLibs.$Arch.Debug.14.00.appx"

    Write-Host "Debug VCLibs successfully installed for $Arch."
}
