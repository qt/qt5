# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

Write-Host "Caching Gradle distributions and dependencies"

$gradleProjectSource = "$PSScriptRoot\..\shared\gradle\project"
$gradleDistributionMirror = "\\ci-files01-hki.ci.qt.io\provisioning\gradle"
$gradleInitScript = "init.d\nexus-mirror.gradle"

# Route every Gradle repository through the internal Nexus mirror.
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gradle\init.d" | Out-Null
Copy-Item -Force "$PSScriptRoot\..\shared\gradle\$gradleInitScript" "$env:USERPROFILE\.gradle\$gradleInitScript"

# Returns the hash of the Gradle binary distribution for a given Gradle version.
# Gradle calculates the hash as base36(md5(distributionUrl)).
function Get-GradleDistributionHash([string]$Version) {
    # 1. Read the project's distributionUrl.
    $distributionUrl = Get-Content "$gradleProjectSource\gradle\wrapper\gradle-wrapper.properties" |
        Where-Object { $_ -like 'distributionUrl=*' }
    $distributionUrl = $distributionUrl -replace '^distributionUrl=', ''
    # 2. Unescape the Java-properties (e.g. '\:').
    $distributionUrl = $distributionUrl -replace '\\:', ':'
    # 3. Swap in the requested version while maintaining the distribution URL.
    $distributionUrl = $distributionUrl -replace 'gradle-[0-9.]+-bin\.zip', "gradle-$Version-bin.zip"

    # .NET BigInteger is little-endian two's complement, so reverse the md5 and
    # append a 0 byte to get the same positive value Gradle uses.
    $md5 = [System.Security.Cryptography.MD5]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($distributionUrl))
    [array]::Reverse($md5)
    $number = [System.Numerics.BigInteger]::new([byte[]]($md5 + 0))

    # Convert the md5 to base36: repeatedly take the next digit (number % 36) and
    # divide by 36, prepending each digit's character.
    $alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    $hash = ""
    while ($number -gt 0) {
        $digit = [int]($number % 36)
        $hash = $alphabet[$digit] + $hash
        $number = $number / 36
    }
    return $hash
}

# Seed a Gradle distribution binary into ~/.gradle from the internal mirror.
function Seed-GradleDistribution([string]$Version, [string]$Sha256) {
    $distributionDir = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-$Version-bin\$(Get-GradleDistributionHash $Version)"
    if (Test-Path "$distributionDir\gradle-$Version-bin.zip.ok") {
        return
    }
    New-Item -ItemType Directory -Force -Path $distributionDir | Out-Null
    $zip = "$distributionDir\gradle-$Version-bin.zip"
    $url = "$gradleDistributionMirror\gradle-$Version-bin.zip"
    Download $url $url $zip
    Verify-Checksum $zip $Sha256
    Extract-7Zip $zip $distributionDir
    Remove $zip
    New-Item -ItemType File -Force -Path "$distributionDir\gradle-$Version-bin.zip.ok" | Out-Null
}

# Populate ~/.gradle/caches by priming the shared project for each Gradle and AGP profile.
function Cache-GradleProfile([string[]]$VersionProfile) {
    Write-Host "Caching Gradle profile $($VersionProfile -join ' ')"
    $project = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    Copy-Item -Recurse -Force $gradleProjectSource $project

    $props = "$project\gradle\wrapper\gradle-wrapper.properties"
    foreach ($kv in $VersionProfile) {
        if ($kv -like "gradle=*") {
            $val = ($kv -split '=', 2)[1]
            (Get-Content $props) -replace "gradle-[0-9.]+-bin\.zip", "gradle-$val-bin.zip" | Set-Content $props
        }
    }

    $toml = "$project\gradle\libs.versions.toml"
    foreach ($kv in $VersionProfile) {
        if ($kv -like "gradle=*") {
            continue
        }
        $key, $val = $kv -split '=', 2
        $inVersions = $false
        (Get-Content $toml) | ForEach-Object {
            if ($_ -match '^\[') {
                $inVersions = $_ -eq '[versions]'
            }
            if ($inVersions -and $_ -match "^$key = ") {
                "$key = `"$val`""
            } else {
                $_
            }
        } | Set-Content $toml
    }

    $env:ANDROID_SDK_ROOT = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "Machine")
    Push-Location $project
    cmd /c "gradlew.bat --no-daemon build"
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        throw "Gradle caching failed"
    }
    Remove-Item -Recurse -Force $project
}

# Cache both the current and the previous versions to avoid issues during bumps.
Seed-GradleDistribution "9.3.1" "b266d5ff6b90eada6dc3b20cb090e3731302e553a27c5d3e4df1f0d76beaff06"
Cache-GradleProfile "gradle=9.3.1", "agp=9.0.0"
Seed-GradleDistribution "9.5.1" "bafc141b619ad6350fd975fc903156dd5c151998cc8b058e8c1044ab5f7b031f"
Cache-GradleProfile "gradle=9.5.1", "agp=9.2.1"

Write-Host "Cached Gradle distributions and dependencies under $env:USERPROFILE\.gradle."
