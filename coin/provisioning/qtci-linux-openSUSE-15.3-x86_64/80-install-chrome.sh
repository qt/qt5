#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
set -ex

# This script will install up-to-date google Chrome needed for Webassembly auto tests.

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

# Webassembly auto tests run requires latest Chrome. Let's use the latest stable one which means we can't cache this
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome

# Add the Google public signing key
externalUrl="https://dl.google.com/linux/linux_signing_key.pub"
Download "$externalUrl" "/tmp/linux_signing_key.pub"
sudo rpm --import /tmp/linux_signing_key.pub

# Update the repo cache of zypper and install Chrome
sudo zypper ref -f
sudo zypper -nq install --no-confirm google-chrome-stable

# Install Chromedriver Chromium
sudo zypper -nq install chromedriver

