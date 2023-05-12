#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install Git Large File Storage

set -ex

curl -L https://packagecloud.io/github/git-lfs/gpgkey | sudo apt-key add -
sudo apt-add-repository 'deb https://packagecloud.io/github/git-lfs/ubuntu/ xenial main'
sudo apt update
sudo apt install git-lfs
