#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Sources the shell profile files where SetEnvVar.sh writes environment variables.

if uname -a |grep -q "Ubuntu"; then
    if lsb_release -a |grep "Ubuntu 22.04"; then
        source ~/.bash_profile
    else
        source ~/.profile
    fi
else
    source ~/.bashrc
fi
