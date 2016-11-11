. "$PSScriptRoot\helpers.ps1"

$installer = "c:\users\qt\downloads\conan-win_0_15_0.exe"

Download https://github.com/conan-io/conan/releases/download/0.15.0/conan-win_0_15_0.exe http://ci-files01-hki.ci.local/input/windows/conan/conan-win_0_15_0.exe $installer
Verify-Checksum $installer "AE8DB31B34A9B88EA227F0FE283FC0F003D2BFDD"
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
        $manifestsDir = "$($_.DirectoryName)\$($_.BaseName).manifests"
        New-Item $outpwd -Type directory -Force
        Start-Process-Logged `
            "C:\Utils\Conan\conan\conan.exe" `
            -WorkingDirectory $outpwd `
            -ArgumentList "install -f $($_.FullName) --verify $($manifestsDir)", `
                '-s', ('compiler="' + $Compiler + '"'), `
                "-s os=Windows -s arch=$($Arch) -s compiler.version=$($CompilerVersion) $($runtimeArg)" `
            -NoNewWindow -Wait -Verbose
    }
}
