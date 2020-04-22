# Disable Microsoft's digital assistant Cortona
echo "Disabling Cortona"
reg.exe ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /V AllowCortana /T REG_dWORD /D 0 /F
