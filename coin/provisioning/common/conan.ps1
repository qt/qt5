. "$PSScriptRoot\helpers.ps1"

$installer = "c:\users\qt\downloads\conan-win_0_12_0.exe"

Download https://s3-eu-west-1.amazonaws.com/conanio-production/downloads/conan-win_0_12_0.exe http://ci-files01-hki.ci.local/input/conan/conan-win_0_12_0.exe $installer
Verify-Checksum $installer "719F30E6EED03149D75CDB28F80A7B873B43FF51"
& $installer /DIR=C:\Utils\Conan /VERYSILENT | Out-Null

[Environment]::SetEnvironmentVariable("CI_CONAN_BUILDINFO_DIR", "C:\Utils\conanbuildinfos", "Machine")

function Start-Process-Logged
{
    Write-Host "Start-Process", $args
    Start-Process @args
}

function Run-Conan-Install
{
    Param (
        [string]$ConanfilesDir,
        [string]$BuildinfoDir,
        [string]$Arch,
        [string]$Compiler,
        [string]$CompilerVersion,
        [string]$CompilerRuntime
    )

    if ($CompilerRuntime) {
        $runtimeArg = "-s compiler.runtime=$($CompilerRuntime)"
    }

    Get-ChildItem -Path "$ConanfilesDir\*.txt" |
    ForEach-Object {
        $outpwd = "C:\Utils\conanbuildinfos\$($BuildinfoDir)\$($_.BaseName)"
        New-Item $outpwd -Type directory -Force
        Start-Process-Logged `
            "C:\Utils\Conan\conan\conan.exe" `
            -WorkingDirectory $outpwd `
            -ArgumentList "install -i -f $($_.FullName)", `
                '-s', ('compiler="' + $Compiler + '"'), `
                "-s os=Windows -s arch=$($Arch) -s compiler.version=$($CompilerVersion) $($runtimeArg)" `
            -NoNewWindow -Wait -Verbose
    }
}
