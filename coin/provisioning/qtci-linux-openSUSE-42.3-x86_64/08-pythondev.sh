#!/usr/bin/env bash
# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

sudo pkcon -y refresh
sudo pkcon -y install python-devel python-virtualenv

# install python3
sudo pkcon -y install libpython3_4m1_0 python3-base python3 python3-pip python3-devel python3-virtualenv
