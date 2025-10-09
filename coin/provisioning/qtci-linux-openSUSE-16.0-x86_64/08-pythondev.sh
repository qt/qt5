#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside and emsdk for WebAssembly

set -ex

source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# install python3
sudo zypper -nq install python313-base python313-devel python313-pip python313-virtualenv python313-wheel
python3.13 -m pip install selenium netifaces scache brotli httpcompressionserver
python3.13 -m pip install -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

SetEnvVar "PYTHON3_EXECUTABLE" "/usr/bin/python3.13"

# Provisioning during installation says:
# 'Defaulting to user installation because normal site-packages is not writeable'
# So it implicitly uses pip install --user, hence the path.
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/home/qt/.local/bin"
