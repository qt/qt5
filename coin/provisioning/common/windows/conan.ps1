#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Copyright (C) 2019 Konstantin Tokarev <annulen@yandex.ru>
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

. "$PSScriptRoot\helpers.ps1"

$scriptsPath = "C:\Python36\Scripts"

Run-Executable "$scriptsPath\pip3.exe" "install -r $PSScriptRoot\conan_requirements.txt"
Write-Output "Conan = 1.29.0" >> ~\versions.txt

# Use Qt Project repository by default
Run-Executable "$scriptsPath\conan.exe" "remote add qtproject https://api.bintray.com/conan/qtproject/conan --insert --force"

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
        [string]$CompilerLibcxx,
        [string]$CompilerException,
        [string]$CompilerThreads
    )

    if ($CompilerRuntime) {
        $extraArgs += " -s compiler.runtime=$CompilerRuntime"
    }

    if ($CompilerLibcxx) {
        $extraArgs += " -s compiler.libcxx=$CompilerLibcxx"
    }

    if ($CompilerException) {
        $extraArgs += " -s compiler.exception=$CompilerException"
    }

    if ($CompilerThreads) {
        $extraArgs += " -s compiler.threads=$CompilerThreads"
    }

    $manifestsDir = "$PSScriptRoot\conan_manifests"
    $buildinfoRoot = "C:\Utils\conanbuildinfos"

    # Make up to 5 attempts for all download operations in conan
    $env:CONAN_RETRY = "5"

    Get-ChildItem -Path "$ConanfilesDir\*.txt" |
    ForEach-Object {
        $conanfile = $_.FullName
        $outpwd = "$buildinfoRoot\$BuildinfoDir\$($_.BaseName)"
        New-Item $outpwd -Type directory -Force | Out-Null

        Push-Location $outpwd
        Run-Executable "$scriptsPath\conan.exe" "install --no-imports --verify $manifestsDir", `
            '-s', ('compiler="' + $Compiler + '"'), `
            "-s os=Windows -s arch=$Arch -s compiler.version=$CompilerVersion $extraArgs $conanfile"
        Pop-Location

        Copy-Item -Path $conanfile -Destination "$outpwd\conanfile.txt"
    }
}
