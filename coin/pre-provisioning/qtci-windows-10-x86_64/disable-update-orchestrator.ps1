# Disable UpdateOrchestrator

$name = "UpdateOrchestrator"
$path = "C:\Windows\System32\Tasks\Microsoft\Windows\$name"

takeown /F $path /A /R
icacls $path /grant Administrators:F /T
del "$path\Schedule Scan"
del "$path\Schedule Scan Static Task"
del "$path\UpdateModelTask"
del "$path\USO_UxBroker"

# Disable Update orchestrator service
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /V Start /T REG_dWORD /D 4 /F
