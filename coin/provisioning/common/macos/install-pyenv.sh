#!/usr/bin/env bash
#Copyright (C) 2025 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

installerFile="pyenv-installer"
sha="1c2f20c26dc8bb7409a6031e8777c0c1b2aae9da"
cacheUrl="https://ci-files01-hki.ci.qt.io/input/python/pyenv/${installerFile}"
target="${installerFile}"

DownloadURL "$cacheUrl" "" "$sha" "$target"
chmod +x "$target"
"./$target"
SetEnvVar "PYENV_ROOT" "/Users/qt/.pyenv"
SetEnvVar "PATH" "\$PYENV_ROOT/bin:\$PATH"
rm -f "$target"
