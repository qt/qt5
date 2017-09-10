#!/bin/bash
# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside
sudo zypper -nq install python-devel python-virtualenv

# install python3
sudo zypper -nq install python3 python3-pip python3-virtualenv
