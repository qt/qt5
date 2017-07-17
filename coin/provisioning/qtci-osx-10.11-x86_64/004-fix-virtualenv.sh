#!/usr/bin/env bash

# macOS 10.11 template doesn't have working virtualenv installation.
# To fix that, we first have to install pip to install virtualenv
# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py
rm get-pip.py

# remove link pointing to broken virtualenv
sudo rm /opt/local/bin/virtualenv
sudo pip install virtualenv

# fix the link. This is optional, while the new installation is
# already in PATH, but there will be virtualenv-2.6 in /opt/local/bin
# which might be confusing
sudo ln -s /usr/local/bin/virtualenv /opt/local/bin/virtualenv
