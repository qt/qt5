#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

echo "Disable Network Time Protocol (NTP)"

if uname -a |grep -q "Ubuntu\|Debian" ; then
    sudo timedatectl set-ntp false
elif cat /etc/os-release | grep "PRETTY_NAME" | grep -q "Leap 15"; then
    (sudo systemctl stop chronyd && sudo systemctl disable chronyd)
elif cat /etc/os-release |grep "SUSE Linux Enterprise Server 15"; then
    sudo timedatectl set-ntp false
else
    sudo systemctl disable ntpd || sudo /sbin/chkconfig ntpd off
fi
