#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

installPackages+=(update-notifier)

if uname -a |grep -q "Ubuntu" ; then
installPackages+=(update-manager-core)
installPackages+=(update-manager)
installPackages+=(python3-distupgrade)
installPackages+=(python3-update-manager)
installPackages+=(ubuntu-release-upgrader-core)
fi

sudo apt -q -y remove "${installPackages[@]}"
