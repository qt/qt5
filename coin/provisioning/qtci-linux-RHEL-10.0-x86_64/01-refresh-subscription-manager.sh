#!/usr/bin/env bash

# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

curl --retry 5 --retry-delay 10 --retry-max-time 60 http://ci-files01-hki.ci.qt.io/input/semisecure/redhat_ak_all_versions_rhc.sh -o "/tmp/redhat_ak.sh" &>/dev/null
sudo chmod 755 /tmp/redhat_ak.sh
sudo /tmp/redhat_ak.sh

# refresh local certificates
sudo subscription-manager refresh

sudo rm -f /tmp/redhat_ak.sh
