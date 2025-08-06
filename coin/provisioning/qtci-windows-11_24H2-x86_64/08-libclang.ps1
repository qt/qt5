# Copyright (C) 2025 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Do not set the default LLVM_INSTALL_DIR for mingw, leave it with msvc for compat
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 llvm-mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" arm64 vs2022 $False $True
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 vs2022
