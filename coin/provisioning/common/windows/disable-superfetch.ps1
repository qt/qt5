Write-Host "Disable superfetch"
reg add "HKLM\System\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 4 /f
