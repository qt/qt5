#!/usr/bin/env bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# See https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces
# and https://bugs.launchpad.net/ubuntu/+source/apparmor/+bug/2046844/comments/89
sudo bash -c 'cat > /etc/apparmor.d/bwrap' << EOF
# This profile allows everything and only exists to give the
# application a name instead of having the label "unconfined"

abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,

  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/bwrap>
}
EOF

sudo apparmor_parser -r /etc/apparmor.d/bwrap
