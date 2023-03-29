#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

sudo zypper -nq install python-devel python-xml

# install python3
sudo zypper -nq install python3-base python3 python3-pip python3-devel python3-virtualenv python3-wheel
