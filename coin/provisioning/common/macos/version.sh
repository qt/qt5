#!/usr/bin/env bash
# Copyright (C) 2016 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will print all installed software to provision log.
# Script needs to be named so that it will be ran at last during provisioning

# Print all build machines versions to provision log
echo "*********************************************"
echo "***** SW VERSIONS *****"
cat ~/versions.txt
echo "*********************************************"
echo "*************** mount ***********************"
mount
echo "*********************************************"
echo "*************** df **************************"
df -h
echo "*********************************************"
