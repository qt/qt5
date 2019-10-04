function Verify-Checksum
{
    Param (
        [string]$File=$(throw("You must specify a filename to get the checksum of.")),
        [string]$Expected=$(throw("Checksum required")),
        [ValidateSet("sha256","sha1","md5")][string]$Algorithm="sha1"
    )
    Write-Host "Verifying checksum of $File"
    $fs = new-object System.IO.FileStream $File, "Open"
    $algo = [type]"System.Security.Cryptography.$Algorithm"
    $crypto = $algo::Create()
    $hash = [BitConverter]::ToString($crypto.ComputeHash($fs)).Replace("-", "")
    $fs.Close()
    if ($hash -ne $Expected) {
        throw "Checksum verification failed, got: '$hash' expected: '$Expected'"
    }
}

function Run-Executable
{
    Param (
        [string]$Executable=$(throw("You must specify a program to run.")),
        [string[]]$Arguments
    )

    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()

    if ([string]::IsNullOrEmpty($Arguments)) {
        Write-Host "Running `"$Executable`""
        $p = Start-Process -FilePath "$Executable" -Wait -PassThru `
            -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
    } else {
        Write-Host "Running `"$Executable`" with arguments `"$Arguments`""
        $p = Start-Process -FilePath "$Executable" -ArgumentList $Arguments -PassThru `
            -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        Wait-Process -InputObject $p
    }

    $stdoutContent = [System.IO.File]::ReadAllText($stdoutFile)
    $stderrContent = [System.IO.File]::ReadAllText($stderrFile)
    Remove-Item -Path $stdoutFile, $stderrFile -Force -ErrorAction Ignore

    $hasOutput = $false
    if ([string]::IsNullOrEmpty($stdoutContent) -eq $false -or [string]::IsNullOrEmpty($stderrContent) -eq $false) {
        $hasOutput = $true
        Write-Host
        Write-Host "======================================================================"
    }
    if ([string]::IsNullOrEmpty($stdoutContent) -eq $false) {
        Write-Host "stdout of `"$Executable`":"
        Write-Host "======================================================================"
        Write-Host $stdoutContent
        Write-Host "======================================================================"
    }
    if ([string]::IsNullOrEmpty($stderrContent) -eq $false) {
        Write-Host "stderr of `"$Executable`":"
        Write-Host "======================================================================"
        Write-Host $stderrContent
        Write-Host "======================================================================"
    }
    if ($hasOutput) {
        Write-Host
    }
    if ($p.ExitCode -ne 0) {
        throw "Process $($Executable) exited with exit code $($p.ExitCode)"
    }
}

function Extract-tar_gz
{
    Param (
        [string]$Source,
        [string]$Destination
    )
    Write-Host "Extracting '$Source' to '$Destination'..."

    if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null) {
        $zipExe = join-path (${env:ProgramFiles(x86)}, ${env:ProgramFiles}, ${env:ProgramW6432} -ne $null)[0] '7-zip\7z.exe'
        if (-not (test-path $zipExe)) {
            $zipExe = "C:\Utils\sevenzip\7z.exe"
            if (-not (test-path $zipExe)) {
                throw "Could not find 7-zip."
            }
        }
    } else {
        $zipExe = "7z.exe"
    }
    Run-Executable "cmd.exe"  "/C $zipExe x -y `"$Source`" -so | $zipExe x -y -aoa -si -ttar `"-o$Destination`""
}

function Extract-7Zip
{
    Param (
        [string]$Source,
        [string]$Destination,
        [string]$Filter
    )
    Write-Host "Extracting '$Source' to '$Destination'..."

    if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null) {
        $zipExe = join-path (${env:ProgramFiles(x86)}, ${env:ProgramFiles}, ${env:ProgramW6432} -ne $null)[0] '7-zip\7z.exe'
        if (-not (test-path $zipExe)) {
            $zipExe = "C:\Utils\sevenzip\7z.exe"
            if (-not (test-path $zipExe)) {
                throw "Could not find 7-zip."
            }
        }
    } else {
        $zipExe = "7z.exe"
    }

    if ([string]::IsNullOrEmpty($Filter)) {
        Run-Executable "$zipExe" "x -y `"-o$Destination`" `"$Source`""
    } else {
        Run-Executable "$zipExe" "x -y -aoa `"-o$Destination`" `"$Source`" $Filter"
    }
}

function BadParam
{
    Param ([string]$Description)
    throw("You must specify $Description")
}

function Get-DefaultDownloadLocation
{
    return $env:USERPROFILE + "\downloads\"
}

function Get-DownloadLocation
{
    Param ([string]$TargetName = $(BadParam("a target filename")))
    return (Get-DefaultDownloadLocation) + $TargetName
}

function Download
{
    Param (
        [string] $OfficialUrl = $(BadParam("the official download URL")),
        [string] $CachedUrl   = $(BadParam("the locally cached URL")),
        [string] $Destination = $(BadParam("a download target location"))
    )
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        Write-Host "Downloading from cached location ($CachedUrl) to $Destination"
        if ($CachedUrl.StartsWith("http")) {
            Invoke-WebRequest -UseBasicParsing $CachedUrl -OutFile $Destination
        } else {
            Copy-Item $CachedUrl $Destination
        }
    } catch {
        Write-Host "Cached download failed: Downloading from official location: $OfficialUrl"
        Invoke-WebRequest -UseBasicParsing $OfficialUrl -OutFile $Destination
    }
}

function Add-Path
{
    Param (
        [string]$Path
    )
    Write-Host "Adding $Path to Path"

    $oldPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    [Environment]::SetEnvironmentVariable("Path", $oldPath + ";$Path", [EnvironmentVariableTarget]::Machine)
    $Env:PATH = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
}

function Prepend-Path
{
    Param (
        [string]$Path
    )
    Write-Host "Adding $Path to Path"

    $oldPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    [Environment]::SetEnvironmentVariable("Path", "$Path;" + $oldPath, [EnvironmentVariableTarget]::Machine)
    $Env:PATH = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
}

function Set-EnvironmentVariable
{
    Param (
        [string]$Key = $(BadParam("a key")),
        [string]$Value = $(BadParam("a value."))
    )
    Write-Host "Setting environment variable `"$($Key)`" to `"$($Value)`""

    [Environment]::SetEnvironmentVariable($Key, $Value, [EnvironmentVariableTarget]::Machine)
}

function Is64BitWinHost
{
    return [environment]::Is64BitOperatingSystem
}

function IsProxyEnabled {
    return (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyEnable
}

function Get-Proxy {
    return (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer
}

function Retry{
    <#
    usage:
    Retry{CODE}
    Retry{CODE} <num of retries> <delay_s>
    #delay is in seconds
    #>
    Param(
        [Parameter(mandatory=$true)]
        [scriptblock]$command,
        [int][ValidateRange(1, 20)]$retry = 5,
        [int][ValidateRange(1, 60)]$delay_s = 5
    )
    $success=$false
    $retry_count=0
    do{
        try {
            Invoke-Command -ScriptBlock $command
            $success=$true
        }
        catch {
            $retry_count++
            Write-Host "Error: $_, try: $retry_count, retrying in $delay_s seconds"
            Start-Sleep -Seconds $delay_s
        }
    } until ($success -or $retry+1 -le $retry_count)

    if (-not $success) {
        Throw("Failed to run command successfully in $retry_count tries")
    }
}

function Remove {

    Param (
        [string]$Path = $(BadParam("a path"))
    )
    Write-Host "Removing $Path"
    $i = 0
    While ( Test-Path($Path) ){
        Try{
            remove-item -Force -Recurse -Path $Path -ErrorAction Stop
        }catch{
            $i +=1
            if ($i -eq 5) {exit 1}
            Write-Verbose "$Path locked, trying again in 5"
            Start-Sleep -seconds 5
        }
    }
}

function DisableSchedulerTask {

    Param (
        [string]$Task = $(BadParam("a task"))
    )

    Write-Host "Disabling $Task from Task Scheduler"
    SCHTASKS /Change /TN "Microsoft\Windows\$Task" /DISABLE
}

function DeleteSchedulerTask {

   Param (
        [string]$Task = $(BadParam("a task"))
    )

    Write-Host "Disabling $Task from Task Scheduler"
    SCHTASKS /DELETE /TN "Microsoft\Windows\$Task" /F
}
