#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# We need to disable selinux while we are overwriting some binaries
# required by it. If this is not done, ICU provisioning will create
# template that is not booting.

sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/g  /etc/selinux/config
