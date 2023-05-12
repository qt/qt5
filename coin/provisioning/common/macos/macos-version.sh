#!/usr/bin/env bash
# Copyright (C) 2016 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script needs to be called last during provisioning so that the software information will show up last in provision log.

set -ex

# Print all build machines versions to provision log
echo "*********************************************" >> ~/versions.txt
echo "***** macOS version *****" >> ~/versions.txt
sw_vers >> ~/versions.txt
echo "***** All installed packages *****" >> ~/versions.txt
echo "***** HomeBrew *****" >> ~/versions.txt
brew list --versions >> ~/versions.txt
echo "***** Apple's installer *****" >> ~/versions.txt
pkgutil --pkgs >> ~/versions.txt
echo "*********************************************" >> ~/versions.txt

"$(dirname "$0")/version.sh"
