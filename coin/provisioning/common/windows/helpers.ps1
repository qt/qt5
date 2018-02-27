function Verify-Checksum
{
    Param (
        [string]$File=$(throw("You must specify a filename to get the checksum of.")),
        [string]$Expected=$(throw("Checksum required")),
        [ValidateSet("sha1","md5")][string]$Algorithm="sha1"
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
    if ([string]::IsNullOrEmpty($Arguments)) {
        Write-Host "Running `"$Executable`""
        $p = Start-Process -FilePath "$Executable" -Wait -PassThru
    } else {
        Write-Host "Running `"$Executable`" with arguments `"$Arguments`""
        $p = Start-Process -FilePath "$Executable" -ArgumentList $Arguments -Wait -PassThru
    }
    if ($p.ExitCode -ne 0) {
        throw "Process $($Executable) exited with exit code $($p.ExitCode)"
    }
}

function Extract-7Zip
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

    Run-Executable "$zipExe" "x -y `"-o$Destination`" `"$Source`""
}

function Extract-Zip
{
    Param (
        [string]$Source,
        [string]$Destination
    )
    Write-Host "Extracting '$Source' to '$Destination'..."

    New-Item -ItemType Directory -Force -Path $Destination
    $shell = new-object -com shell.application
    $zipfile = $shell.Namespace($Source)
    $destinationFolder = $shell.Namespace($Destination)
    $destinationFolder.CopyHere($zipfile.Items(), 16)
}

function Extract-Dev-Folders-From-Zip
{
    Param (
        [string]$package,
        [string]$zipDir,
        [string]$installPath
    )

    $shell = new-object -com shell.application

    Write-Host "Extracting contents of $package"
    foreach ($subDir in "lib", "include", "bin", "share") {
        $zip = $shell.Namespace($package + "\" + $zipDir + "\" + $subDir)
        if ($zip) {
            Write-Host "Extracting $subDir from zip archive"
        } else {
            Write-Host "$subDir is missing from zip archive - skipping"
            continue
        }
        $destDir = $installPath + "\" + $subdir
        New-Item $destDir -type directory
        $destinationFolder = $shell.Namespace($destDir)
        $destinationFolder.CopyHere($zip.Items(), 16)
    }
}

function BadParam
{
    Param ([string]$Description)
    throw("You must specify $Description")
}

function Download
{
    Param (
        [string] $OfficialUrl = $(BadParam("the official download URL")),
        [string] $CachedUrl   = $(BadParam("the locally cached URL")),
        [string] $Destination = $(BadParam("a download target location"))
    )
    $ProgressPreference = 'SilentlyContinue'
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

function isProxyEnabled {
    return (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyEnable
}

function getProxy {
    return (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer
}
