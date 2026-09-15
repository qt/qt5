# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\install-ffmpeg-common.ps1"

function InstallMingwFfmpeg {
    $config = GetFfmpegDefaultConfiguration
    $mingwPath = [System.Environment]::GetEnvironmentVariable("MINGW_PATH", [System.EnvironmentVariableTarget]::Machine)
    return InstallFfmpeg -config $config -buildSystem "mingw" -msystem "MINGW" -additionalPath "$mingwPath\bin" -ffmpegDirEnvVar "FFMPEG_DIR_MINGW" -shared $true
}
