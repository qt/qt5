. "$PSScriptRoot\helpers.ps1"

$scriptsPath = "C:\Python27\Scripts"

Run-Executable "$scriptsPath\pip.exe" "install --upgrade conan==0.24.0"

# Use Qt Project repository by default
Run-Executable "$scriptsPath\conan.exe" "remote add qtproject https://api.bintray.com/conan/qtproject/conan --insert"

Set-EnvironmentVariable "CI_CONAN_BUILDINFO_DIR" "C:\Utils\conanbuildinfos"

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

    $manifestsDir = "$PSScriptRoot\conan_manifests"

    Get-ChildItem -Path "$ConanfilesDir\*.txt" |
    ForEach-Object {
        $conanfile = $_.FullName
        $outpwd = "C:\Utils\conanbuildinfos\$($BuildinfoDir)\$($_.BaseName)"
        New-Item $outpwd -Type directory -Force

        for ($i = 1; $i -le 5; $i++) {
            try {
                Push-Location $outpwd
                Run-Executable "$scriptsPath\conan.exe" "install -f $conanfile --no-imports --verify $manifestsDir", `
                    '-s', ('compiler="' + $Compiler + '"'), `
                    "-s os=Windows -s arch=$Arch -s compiler.version=$CompilerVersion $extraArgs" `
                break;
            } catch {
                if ($i -eq 5) {
                    throw "Could not install conan content"
                }
            } finally {
                Pop-Location
            }
        }

        Copy-Item -Path $conanfile -Destination "$outpwd\conanfile.txt"
    }
}

Write-Output "Conan = 0.24.0" >> ~\versions.txt
