#!/usr/bin/env bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Disable ptrace
echo "kernel.yama.ptrace_scope = 0" | sudo tee /etc/sysctl.d/10-ptrace.conf

BASEDIR=$(dirname "$0")
"$BASEDIR"/../common/linux/enable_test_stacktraces.sh
