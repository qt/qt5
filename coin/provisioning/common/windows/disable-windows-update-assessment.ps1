# The Windows as a Service (WaaS) Update Assessment Platform provides information on a device's Windows updates.

$limit = (Get-Date).AddMinutes(20)
$path = "C:\Windows\System32\WaaSAssessment.dll"

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
