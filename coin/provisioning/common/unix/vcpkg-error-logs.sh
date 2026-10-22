#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# vcpkg only prints the paths of the failed build step logs, which are gone once the CI VM is
# discarded. Print their contents, listed in buildtrees/<port>/error-logs-<triplet>.txt,
# so the CI log shows what failed.
printVcpkgErrorLogs() {
    local list log
    for list in "$VCPKG_ROOT"/buildtrees/*/error-logs-*.txt; do
        [ -f "$list" ] || continue
        while IFS= read -r log; do
            [ -f "$log" ] || continue
            # Configure failures also list these, but they are large and the error is in the -out/-err logs.
            case "$log" in
                *-CMakeCache.txt.log|*-CMakeConfigureLog.yaml.log) continue ;;
            esac
            echo "===== Contents of $log ====="
            cat "$log"
        done < "$list"
    done
}
