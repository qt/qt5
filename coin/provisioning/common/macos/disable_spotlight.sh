#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Allow retry in case mdutil fails with first tries
set +e

disableSpotlight() {
    # Disable spotlight and and stop indexing
    sudo mdutil -a -i off || return 1
    sudo mdutil -a -i off / || return 1
    # Disable spotlight indexing /Volumes
    sudo mdutil -i off /Volumes || return 1
    # Erase spotlight index
    sudo mdutil -E / || return 1
}

fixUnknownIndexingState() {
    echo "Fix unknown indexing state by enabling indexing back one by one"
    sudo mdutil -i on / || return 1
    sudo mdutil -i on /System/Volumes/Preboot || return 1
    sudo mdutil -i on /System/Volumes/Data || return 1
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
        echo "Failed to disable spotlight, $i run fix and retry..."
        fixUnknownIndexingState
        sleep 2
    fi
done

exit $res
