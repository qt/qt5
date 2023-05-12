#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# On macOS the sha1 tool is named 'shasum' while on all other unix systems it is called 'sha1sum'.
# In order to make all unix provioning scripts run on macOS without special case handling
# a symbolic link is created.
# The shasum tool is a perl script which does some globbing to determine the perl version. The
# symbolic link has to point directly to the binary including the perl version.
# Additionally the CI seems to have multiple parallel perl versions installed which causes
# multiple shasum tools to be present (shasum5.16, shasum5.18).
#
# Currently this is
#     /usr/local/bin/sha1sum -> /usr/bin/shasum5.18

[ -d /usr/local/bin ] || sudo mkdir -p /usr/local/bin
# shellcheck disable=SC2012
SHASUM_TOOLNAME=$(ls -r /usr/bin/shasum?.* | head -n1)
sudo ln -s "${SHASUM_TOOLNAME}" /usr/local/bin/sha1sum
