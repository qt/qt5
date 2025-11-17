#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

sudo zypper -nq install python-devel python-xml

# install python3
sudo zypper -nq install python311-base python311-devel python311-pip python311-virtualenv python311-wheel
python3.11 -m pip install selenium netifaces scache
python3.11 -m pip install -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

SetEnvVar "PYTHON3_EXECUTABLE" "/usr/bin/python3.11"

# Provisioning during installation says:
# 'Defaulting to user installation because normal site-packages is not writeable'
# So it implicitly uses pip install --user, hence the path.
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/home/qt/.local/bin"

# Set SBOM_PYTHON_INTERP_PATH to Python3 instance which was used to install SBOM packages from requirements
SetEnvVar "SBOM_PYTHON_INTERP_PATH" "/usr/bin/python3.11"
