# Allow SMB client guest logons to SMB server.
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /V AllowInsecureGuestAuth /T REG_dWORD /D 1 /F
