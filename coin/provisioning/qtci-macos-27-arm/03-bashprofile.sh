#!/usr/bin/env sh
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Read .bashrc if exist
printf -- "# Get the aliases and functions\nif [ -f ~/.bashrc ]; then\n        . ~/.bashrc\nfi\n" >> ~/.bash_profile

