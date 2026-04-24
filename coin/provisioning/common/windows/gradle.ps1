# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

Write-Host "Caching Gradle distribution and dependencies"
$gradleCacheFileName = "gradle_9.3.1_windows_cache_v2.zip"
$gradleCacheCachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\gradle\$gradleCacheFileName"
$gradleCacheOfficialUrl = $gradleCacheCachedUrl
$gradleCacheChecksum = "fcd653a1f4f30da9074a7aa7cfcad9219ed57d96"
$gradleCacheZip = "C:\Windows\Temp\$gradleCacheFileName"
Download $gradleCacheOfficialUrl $gradleCacheCachedUrl $gradleCacheZip
Verify-Checksum $gradleCacheZip $gradleCacheChecksum
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gradle"
Extract-7Zip $gradleCacheZip "$env:USERPROFILE"
Remove $gradleCacheZip

$gradleProjectSource = "$PSScriptRoot\..\shared\gradle\project"
$gradleProjectTarget = "C:\Windows\Temp\gradle_project"
Copy-Item -Recurse -Force $gradleProjectSource $gradleProjectTarget
$env:ANDROID_SDK_ROOT = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "Machine")
Push-Location $gradleProjectTarget
cmd /c "gradlew.bat --no-daemon build"
Pop-Location
if ($LASTEXITCODE -ne 0) { throw "Gradle caching failed" }
