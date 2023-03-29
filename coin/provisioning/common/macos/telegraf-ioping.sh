#!/bin/sh
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Measure I/O latency once, return data in InfluxDB format
#
# Run one ioping command for read, and one for write.
# Each one sends 3 requests and reports the minimum time, in nanoseconds.
# (Because of limitations of ioping, we can't just send one request and get
#  the number back in the batch format. Additionally, the number seems to be
#  fluctuating quite a bit so taking the smallest number out of 3 requests is
#  stabilising it a bit.)


set -e

[ -z "$1" ] && echo "$0 takes a path as a first argument" && exit 1

# Try to run in high priority to avoid slow-downs because of
# factors other than I/O.
renice  -n -10 -p $$  >/dev/null 2>&1 ||  true


rlatency="$(/usr/local/bin/ioping -B -k -c 3 -i 0.1     "$1" | cut -d " " -f 5)"
wlatency="$(/usr/local/bin/ioping -B -k -c 3 -i 0.1 -W  "$1" | cut -d " " -f 5)"

printf "ioping,path=$1 read_latency_ns=%u,write_latency_ns=%u\n" \
       "$rlatency" "$wlatency"
