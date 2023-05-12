#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -ex

breakpad_commit_sha="b988fa74ec18de6214b18f723e48331d9a7802ae"
breakpad_tar="breakpad_$breakpad_commit_sha.tar.gz"
breakpad_tar_url="http://ci-files01-hki.ci.qt.io/input/breakpad/$breakpad_tar"
breakpad_tar_sha="a2d404d2aebc947cdac5840a9bccd65dfafae24c"

linux_syscall_support_commit_sha1="93426bda6535943ff1525d0460aab5cc0870ccaf"
linux_syscall_support_tar="linux-syscall-support_$linux_syscall_support_commit_sha1.tar.gz"
linux_syscall_support_tar_url="http://ci-files01-hki.ci.qt.io/input/linux-syscall-support/$linux_syscall_support_tar"
linux_syscall_support_tar_sha="62565be0920f3661e138d68026b79fbbdc2a11e4"

targetBreakpad="/tmp/$breakpad_tar"
targetSyscall="/tmp/$linux_syscall_support_tar"
installFolder="$HOME"
breakpadHome="$HOME/breakpad"

# shellcheck disable=SC2015
( DownloadURL "$breakpad_tar_url" "$breakpad_tar_url" "$breakpad_tar_sha" "$targetBreakpad" ) && (
    DownloadURL "$linux_syscall_support_tar_url" "$linux_syscall_support_tar_url" "$linux_syscall_support_tar_sha" "$targetSyscall"
    ) && (
    tar -xzf "$targetBreakpad" -C "$installFolder"
    tar -xzf "$targetSyscall" -C "/tmp"
    mv "/tmp/linux-syscall-support/" "$breakpadHome/src/third_party/lss/"
    rm -rf $targetBreakpad
    rm -rf $targetSyscall
    ) || (
    cd "$HOME"
    git clone https://chromium.googlesource.com/breakpad/breakpad "$breakpadHome"
    git clone https://chromium.googlesource.com/linux-syscall-support "$breakpadHome/src/third_party/lss"
    cd "$breakpadHome"
    git checkout "$breakpad_commit_sha"
    cd "$breakpadHome/src/third_party/lss"
    git checkout "$linux_syscall_support_commit_sha1"
    )


SetEnvVar "BREAKPAD_SOURCE_DIR" "$breakpadHome"

echo "breakpad = $breakpad_commit_sha" >> ~/versions.txt
echo "linux_syscall_support = $linux_syscall_support_commit_sha1" >> ~/versions.txt
