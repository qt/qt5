#!/usr/bin/env bash
# Copyright (C) 2020 Konstantin Tokarev <annulen@yandex.ru>
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo yum -y install elfutils-libelf-devel

# shellcheck source=../common/linux/install_dwz.sh
source "${BASH_SOURCE%/*}/../common/linux/install_dwz.sh"

