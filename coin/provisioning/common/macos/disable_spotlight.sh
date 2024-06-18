#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

disableSpotlight() {
    # Disable spotlight and and stop indexing
    sudo mdutil -a -i off
    sudo mdutil -a -i off /
    # Disable spotlight indexing /Volumes
    sudo mdutil -i off /Volumes
    # Erase spotlight index
    sudo mdutil -E /
}

# Disabling spotlight tends to be flaky, add some retry
for i in $(seq 1 5)
do
    disableSpotlight
    res=$?
    if [[ $res -eq 0 ]]
    then
        echo "Spotlight disabled"
        break
    else
        echo "Failed to disable spotlight, $i retry..."
        sleep 2
    fi
done

exit $res
