#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

function InstallPip {

    python=$1

    # Will install pip utility for python
    if [[ $python == "python2.7" ]]; then
        DownloadURL "http://ci-files01-hki.ci.qt.io/input/mac/python27/get-pip.py" "https://bootstrap.pypa.io/2.7/get-pip.py" "c4c5f74586cffe49804f167d95d1710b9750ddf0"
    else
        DownloadURL "http://ci-files01-hki.ci.qt.io/input/mac/get-pip.py" "https://bootstrap.pypa.io/get-pip.py" "209ddf0bb8d1cf06a1f17dd9f21970c76b3d2be2"
    fi
    sudo "$python" get-pip.py
    rm get-pip.py
}
