Get-NetAdapter | Disable-NetAdapterLso
Start-Sleep -s 15  # Give windows some time to adjust network settings
Get-NetAdapter
