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
    $destinationFolder.CopyHere($zipfile.Items())
}
