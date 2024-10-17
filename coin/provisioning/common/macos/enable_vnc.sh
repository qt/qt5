#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.

# This script enables remote management vnc
set -ex

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes
