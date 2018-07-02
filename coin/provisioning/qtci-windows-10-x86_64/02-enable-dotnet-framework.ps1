# The DirectX SDK installer requires .Net framework 3.5 which isn't installed
# by default

$netFeature = "NetFx3"
try {
    $netFeatureState = (Get-WindowsOptionalFeature -Online -FeatureName "$netFeature").State
    if ($netFeatureState -eq "Enabled") {
        Write-Host ".Net Framework is already installed"
        exit 0
    }
} catch {
    Write-Host "Could not find .Net Framework Windows feature."
    exit 1
}

Write-Host "Installing .Net Framework client"
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "$netFeature" -All -NoRestart
} catch {
    Write-Host "Could not install .Net framework"
    exit 1
}
