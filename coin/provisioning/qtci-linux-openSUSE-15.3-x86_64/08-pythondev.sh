#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

sudo zypper -nq install python-devel python-xml

# install python3
sudo zypper -nq install python3-base python3 python3-pip python3-devel python3-virtualenv python3-wheel

# Configure pip
pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
pip config --user set global.extra-index-url https://pypi.org/simple/
