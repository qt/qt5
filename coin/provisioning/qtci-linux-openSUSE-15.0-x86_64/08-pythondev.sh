#!/usr/bin/env bash
# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

sudo pkcon -y refresh
sudo pkcon -y install python-devel python-virtualenv

# install python3
sudo pkcon -y install libpython3_4m1_0 python3-base python3 python3-pip python3-devel python3-virtualenv python3-wheel

# Install all needed packages in a special wheel cache directory
pip3 wheel --wheel-dir "$HOME/python3-wheels" -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "PYTHON3_WHEEL_CACHE" "$HOME/python3-wheels"
