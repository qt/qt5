. "$PSScriptRoot\helpers.ps1"

$scriptsPath = "C:\Python27\Scripts"

& "$scriptsPath\pip.exe" install --upgrade conan==0.16.0

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
        [string]$CompilerRuntime,
        [string]$CompilerLibcxx
    )

    if ($CompilerRuntime) {
        $extraArgs = "-s compiler.runtime=$($CompilerRuntime)"
    }

    if ($CompilerLibcxx) {
        $extraArgs = "-s compiler.libcxx=$($CompilerLibcxx)"
    }

    Get-ChildItem -Path "$ConanfilesDir\*.txt" |
    ForEach-Object {
        $conanfile = $_.FullName
        $outpwd = "C:\Utils\conanbuildinfos\$($BuildinfoDir)\$($_.BaseName)"
        $manifestsDir = "$($_.DirectoryName)\$($_.BaseName).manifests"
        New-Item $outpwd -Type directory -Force

        $process = Start-Process-Logged `
            "$scriptsPath\conan.exe" `
            -WorkingDirectory $outpwd `
            -ArgumentList "install -f $conanfile --no-imports --verify $manifestsDir", `
                '-s', ('compiler="' + $Compiler + '"'), `
                "-s os=Windows -s arch=$Arch -s compiler.version=$CompilerVersion $extraArgs" `
            -NoNewWindow -Wait -Verbose `
            -PassThru # Return process object

        if ($process.ExitCode -ne 0) {
            Write-Host "conan exited with code $($process.ExitCode)"
            Exit(1)
        }

        Copy-Item -Path $conanfile -Destination "$outpwd\conanfile.txt"
    }
}
