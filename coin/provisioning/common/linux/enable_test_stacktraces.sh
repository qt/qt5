#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

### Enable automatic stacktraces in case of fatal errors in QTest.
# This requires that gdb can be found in PATH, and that no
# kernel security settings like yama.ptrace_scope  prevent it.


PROVISIONING_DIR="$(dirname "$0")/../.."
# shellcheck source=../unix/common.sourced.sh
source "$PROVISIONING_DIR/common/unix/common.sourced.sh"


f="/etc/sysctl.d/10-ptrace.conf"
if [ -f $f ]
then
    echo "Modifying $f ..."
    sudo sed -i '/^kernel\.yama\.ptrace_scope *= *[1-9]$/s/[1-9]$/0/'  $f
    # Reload the modified setting, so that we can verify it right afterwards.
    sudo sysctl -p  $f
fi

# Verify that yama.ptrace_scope = 0, if it's supported by the kernel.
ptrace_scope_value=$(sudo sysctl kernel.yama.ptrace_scope 2>/dev/null | sed -E 's/.*([0-9])$/\1/')
if [ -n "$ptrace_scope_value" ] && [ "$ptrace_scope_value" != 0 ]
then
    fatal "kernel.yama.ptrace_scope = $ptrace_scope_value \
        which means that QTest automatic stacktraces will not work"
else
    echo kernel.yama.ptrace_scope = "$ptrace_scope_value"
fi


$CMD_PKG_INSTALL  gdb
