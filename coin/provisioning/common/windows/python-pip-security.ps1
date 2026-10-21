# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

param(
    [Parameter(Mandatory=$true)]
    [string]$install_path
)

. "$PSScriptRoot\helpers.ps1"

$python = "$install_path\python.exe"
$minimumPipVersion = [version]::Parse("26.2.2")
$minimumCertifiVersion = [version]::Parse("2026.10.19")
$pipWheelName = "pip-26.2.2-py3-none-any.whl"
$pipWheelUrl = "https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/$pipWheelName"
$pipWheelCacheURL = "http://ci-files01-hki.ci.qt.io/input/python_module_cache/$pipWheelName"
$pipWheelSha256 = "fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"

if (-not (Test-Path -LiteralPath $python)) {
    throw "Python executable not found: $python"
}

$pip_args = ""
if (IsProxyEnabled) {
    $proxy = Get-Proxy
    Write-Host "Using proxy ($proxy) with pip"
    $pip_args = "--proxy=$proxy"
}

$installedPipVersion = & $python -c "import pip; print(pip.__version__)"
if ($LASTEXITCODE -ne 0) {
    throw "Could not determine pip version for $python."
}
$installedPipVersion = [version]::Parse(($installedPipVersion | Select-Object -First 1).Trim())
if ($installedPipVersion -lt $minimumPipVersion) {
    Write-Host "Installed pip $installedPipVersion is older than $minimumPipVersion; upgrading."
    $pipWheelPath = Join-Path $env:TEMP $pipWheelName
    try {
        Download $pipWheelUrl $pipWheelCacheURL $pipWheelPath
        Verify-Checksum $pipWheelPath $pipWheelSha256
        Run-Executable $python "-m pip install --no-index --no-deps $pipWheelPath"
    } finally {
        Remove $pipWheelPath
    }

    $installedPipVersion = & $python -c "import pip; print(pip.__version__)"
    if ($LASTEXITCODE -ne 0) {
        throw "Could not determine pip version for $python after upgrading."
    }
    $installedPipVersion = [version]::Parse(($installedPipVersion | Select-Object -First 1).Trim())
    if ($installedPipVersion -lt $minimumPipVersion) {
        throw "$python has pip $installedPipVersion; expected at least $minimumPipVersion."
    }
} else {
    Write-Host "Installed pip $installedPipVersion meets minimum $minimumPipVersion; keeping it."
}
Write-Output "Python pip = $installedPipVersion" >> ~/versions.txt

$installedCertifiVersion = & $python -c "import importlib.util; print('missing' if importlib.util.find_spec('certifi') is None else __import__('certifi').__version__)"
if ($LASTEXITCODE -ne 0) {
    throw "Could not determine certifi version for $python."
}
$installedCertifiVersion = ($installedCertifiVersion | Select-Object -First 1).Trim()
$installCertifi = $installedCertifiVersion -eq "missing"
if (-not $installCertifi) {
    $installedCertifiVersion = [version]::Parse($installedCertifiVersion)
    $installCertifi = $installedCertifiVersion -lt $minimumCertifiVersion
}
if ($installCertifi) {
    Write-Host "Installed certifi is missing or older than $minimumCertifiVersion; upgrading."
    Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install --upgrade certifi>=$minimumCertifiVersion"
    $installedCertifiVersion = & $python -c "import certifi; print(certifi.__version__)"
    if ($LASTEXITCODE -ne 0) {
        throw "Could not determine certifi version for $python after upgrading."
    }
    $installedCertifiVersion = [version]::Parse(($installedCertifiVersion | Select-Object -First 1).Trim())
    if ($installedCertifiVersion -lt $minimumCertifiVersion) {
        throw "$python has certifi $installedCertifiVersion; expected at least $minimumCertifiVersion."
    }
} else {
    Write-Host "Installed certifi $installedCertifiVersion meets minimum $minimumCertifiVersion; keeping it."
}
Write-Output "Python certifi = $installedCertifiVersion" >> ~/versions.txt
