# Disable UpdateOrchestrator

$name = "UpdateOrchestrator"
$path = "C:\Windows\System32\Tasks\Microsoft\Windows\$name"

takeown /F $path /A /R
icacls $path /grant Administrators:F /T
SCHTASKS /Change /TN "Microsoft\Windows\$name\Reboot" /DISABLE
del "$path\Combined Scan Download Install"
del "$path\Maintenance Install"
del "$path\Reboot"
del "$path\Policy Install"
del "$path\Refresh Settings"
del "$path\Resume On Boot"
del "$path\USO_UxBroker_Display"
del "$path\USO_UxBroker_ReadyToReboot"

# Disable Update orchestrator service
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /V Start /T REG_dWORD /D 4 /F
