#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# A list of test servers to be provisioned
testserver='apache2 squid vsftpd ftp-proxy danted echo cyrus iptables californium freecoap'
testserver="$testserver apache2_18.04 squid_18.04 vsftpd_18.04 ftp-proxy_18.04 danted_18.04 echo_18.04 cyrus_18.04 iptables_18.04"
