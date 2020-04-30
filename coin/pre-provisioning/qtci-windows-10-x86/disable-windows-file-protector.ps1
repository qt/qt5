# Disable Windows File Protection
# Windows File Protection feature in Microsoft Windows prevents programs from replacing critical Windows system files.

reg.exe ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V SFCDisable /T REG_dWORD /D 0xffffff9d /F
