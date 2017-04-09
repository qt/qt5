function Verify-Checksum
{
    Param (
        [string]$File=$(throw("You must specify a filename to get the checksum of.")),
        [string]$Expected=$(throw("Checksum required")),
        [ValidateSet("sha1","md5")][string]$Algorithm="sha1"
    )
    $fs = new-object System.IO.FileStream $File, "Open"
    $algo = [type]"System.Security.Cryptography.$Algorithm"
    $crypto = $algo::Create()
    $hash = [BitConverter]::ToString($crypto.ComputeHash($fs)).Replace("-", "")
    $fs.Close()
    if ($hash -ne $Expected) {
        Write-Error "Checksum verification failed, got: '$hash' expected: '$Expected'"
    }
}

function Extract-7Zip
{
    Param (
        [string]$Source,
        [string]$Destination
    )
    echo "Extracting '$Source' to '$Destination'..."

    if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null) {
        $zipExe = join-path (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0] '7-zip\7z.exe'
        if (-not (test-path $zipExe)) {
            $zipExe = join-path ${env:ProgramW6432} '7-zip\7z.exe'
            if (-not (test-path $zipExe)) {
                throw "Could not find 7-zip."
            }
        }
    } else {
        $zipExe = "7z.exe"
    }

    & $zipExe x $Source "-o$Destination" -y
}

function Extract-Zip
{
    Param (
        [string]$Source,
        [string]$Destination
    )
    echo "Extracting '$Source' to '$Destination'..."

    New-Item -ItemType Directory -Force -Path $Destination
    $shell = new-object -com shell.application
    $zipfile = $shell.Namespace($Source)
    $destinationFolder = $shell.Namespace($Destination)
    $destinationFolder.CopyHere($zipfile.Items(), 16)
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
    try {
        Invoke-WebRequest -UseBasicParsing $CachedUrl -OutFile $Destination
    } catch {
        Invoke-WebRequest -UseBasicParsing $OfficialUrl -OutFile $Destination
    }
}

function Add-Path
{
    Param (
        [string]$Path
    )
    echo "Adding $Path to Path"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$Path", [EnvironmentVariableTarget]::Machine)
}
