# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install breakpad from sources.
# for manual install.. remember to checkout correct version
#   git clone https://chromium.googlesource.com/breakpad/breakpad
#   git clone https://chromium.googlesource.com/linux-syscall-support breakpad/src/third_party/lss

# Commit used to make this zip breakpad_20181113.tar.gz
#   breakpad
#       commit 66571f4838b2306161f072555cb199049bc68142 (HEAD -> master, origin/master, origin/HEAD)
#   linux-syscall-support
#       commit 93426bda6535943ff1525d0460aab5cc0870ccaf (HEAD -> master, origin/master, origin/HEAD)

# This script installs breakpad.


. "$PSScriptRoot\helpers.ps1"


$breakpad_commit_sha="b988fa74ec18de6214b18f723e48331d9a7802ae"
$breakpad_tar="breakpad_$breakpad_commit_sha.tar.gz"
$breakpad_tar_url="http://ci-files01-hki.ci.qt.io/input/breakpad/$breakpad_tar"
$breakpad_tar_sha="a2d404d2aebc947cdac5840a9bccd65dfafae24c"

$linux_syscall_support_commit_sha1="93426bda6535943ff1525d0460aab5cc0870ccaf"
$linux_syscall_support_tar="linux-syscall-support_$linux_syscall_support_commit_sha1.tar.gz"
$linux_syscall_support_tar_url="http://ci-files01-hki.ci.qt.io/input/linux-syscall-support/$linux_syscall_support_tar"
$linux_syscall_support_tar_sha="62565be0920f3661e138d68026b79fbbdc2a11e4"

$targetBreakpad="$env:tmp\$breakpad_tar"
$targetSyscall="$env:tmp\$linux_syscall_support_tar"
$installFolder = "C:\Utils"

# breakpad
try {
    Download $breakpad_tar_url $breakpad_tar_url $targetBreakpad
    Verify-Checksum $targetBreakpad $breakpad_tar_sha
    Extract-tar_gz $targetBreakpad $installFolder
    Remove "$targetBreakpad"
    # linux-syscall-support
    Download $linux_syscall_support_tar_url $linux_syscall_support_tar_url $targetSyscall
    Verify-Checksum $targetSyscall $linux_syscall_support_tar_sha
    Extract-tar_gz $targetSyscall "$env:tmp\"
    New-Item -ItemType directory -Path "$installFolder\breakpad\third_party\lss"
    Get-ChildItem -Path "$env:tmp\linux-syscall-support\*" -Recurse | Move-Item -Destination "$installFolder\breakpad\third_party\lss"
    Remove "$targetSyscall"
}
catch {
    Write-Host "Cached download failed: Attempping fallback method eg git."
    Set-Location $installFolder
    git.exe clone "https://chromium.googlesource.com/breakpad/breakpad"
    git.exe clone "https://chromium.googlesource.com/linux-syscall-support breakpad\third_party\ssl"
    Set-Location  "breakpad"
    git checkout $breakpad_commit_sha
    Set-Location  "src/third_party/lss"
    git checkout $linux_syscall_support_commit_sha1
}

Set-EnvironmentVariable "BREAKPAD_SOURCE_DIR" "$installFolder\breakpad"

# Write HEAD commit sha to versions txt, so build can be repeated at later date
Write-Output "breakpad = $breakpad_commit_sha" >> ~/versions.txt
Write-Output "linux-syscall-support = $linux_syscall_support_tar" >> ~/versions.txt
