# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\install-ffmpeg-common.ps1"

function InstallLlvmMingwFfmpeg {
    $config = GetFfmpegDefaultConfiguration
    return InstallFfmpeg -config $config -buildSystem "llvm-mingw" -msystem "CLANG64" -ffmpegDirEnvVar "FFMPEG_DIR_LLVM_MINGW" -additionalPath "C:\llvm-mingw\bin" -shared $true
}
