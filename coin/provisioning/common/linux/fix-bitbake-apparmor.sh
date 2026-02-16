#!/usr/bin/env bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# https://discourse.ubuntu.com/t/ubuntu-24-04-lts-noble-numbat-release-notes/39890#p-99950-unprivileged-user-namespace-restrictions
# https://bugs.launchpad.net/ubuntu/+source/apparmor/+bug/2056555/comments/34
sudo bash -c 'cat > /etc/apparmor.d/bitbake' << EOF
abi <abi/4.0>,
include <tunables/global>

profile bitbake /**/bitbake/bin/bitbake* flags=(unconfined) {
        userns,
}
EOF

sudo apparmor_parser -r /etc/apparmor.d/bitbake
