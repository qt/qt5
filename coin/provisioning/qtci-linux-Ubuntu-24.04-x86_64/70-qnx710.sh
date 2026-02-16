#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/linux/qnx_710.sh
source "${BASH_SOURCE%/*}/../common/linux/qnx_710.sh"

# setup NFS
sudo bash -c "echo '/home/qt/work ${qemuNetwork}/24(rw,sync,root_squash,no_subtree_check,anonuid=1000,anongid=1000)' >> /etc/exports"
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
