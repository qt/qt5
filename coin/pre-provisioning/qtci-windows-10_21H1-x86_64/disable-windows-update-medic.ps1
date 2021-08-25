# Windows Update Medic Service (WaaSMedicSvc)'PerformRemediation' helps recover update-related services to the supported configuration.
# WaasMedicSvc keeps re-starting Windows Update, even if it disabled manually.
# Even Admin user don't have privileged to disable PerformRemediation from Task Scheduler which means that WaaSMedicSvc.dll need's to be removed from the system

$limit = (Get-Date).AddMinutes(20)
$path = "C:\Windows\System32\WaaSMedicAgent.exe"

DO {
    takeown /F $path
    icacls  $path /grant Administrators:f
    Write-host "Deleting $path"

    Try {
        del $path
    }
    Catch [System.UnauthorizedAccessException] {
        Write-host "Access to the path '$path' is denied."
        Continue
    }

    if ((Get-Date) -gt $limit) {
        exit 1
    }

}while (Test-Path -Path "$path")
