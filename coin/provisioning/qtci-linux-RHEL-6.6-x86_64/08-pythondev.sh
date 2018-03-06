#!/usr/bin/env bash
# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

sudo yum install -y python-devel python-virtualenv

# install python3
sudo yum install -y python34-devel

# install pip3
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo rm -f get-pip.py
sudo pip3 install virtualenv
