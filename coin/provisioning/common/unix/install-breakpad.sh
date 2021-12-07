#!/usr/bin/env bash

############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
############################################################################

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -ex

breakpad_commit_sha="b988fa74ec18de6214b18f723e48331d9a7802ae"
breakpad_tar="breakpad_$breakpad_commit_sha.tar.gz"
breakpad_tar_url="http://ci-files01-hki.intra.qt.io/input/breakpad/$breakpad_tar"
breakpad_tar_sha="a2d404d2aebc947cdac5840a9bccd65dfafae24c"

linux_syscall_support_commit_sha1="93426bda6535943ff1525d0460aab5cc0870ccaf"
linux_syscall_support_tar="linux-syscall-support_$linux_syscall_support_commit_sha1.tar.gz"
linux_syscall_support_tar_url="http://ci-files01-hki.intra.qt.io/input/linux-syscall-support/$linux_syscall_support_tar"
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
