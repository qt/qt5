#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script needs to be called at the end of provisioning, to clean the cache directory

set -e
set -f
QT_USER="qt"
CACHE=".cache"

echo "---- starting cache cleanup."

# skip if user qt does not exist
echo "---- checking user $QT_USER"
if grep -q "^$QT_USER:" /etc/passwd; then
    echo "(**) found user $QT_USER"
else
    echo "(WW) user $QT_USER not found."
    echo "---- skipping cache cleanup."
    exit 0
fi

# assume /home/qt as ~ won't expand into sudo
CACHEDIR="/home/$QT_USER/$CACHE"

# delete files from a directory if it exists
echo "---- checking cache directory  $CACHEDIR"
if sudo [ -d "$CACHEDIR" ]; then
    if [ "$(sudo ls -A $CACHEDIR)" ]; then
       echo "(WW) cache in $CACHEDIR is not empty."
       echo "---- removing content:"

       # List files and delete in a loop as wildcard won't expand into sudo
       sudo ls -A1 "$CACHEDIR" | while read -r FILE
       do
           echo "--- rm -rf $FILE"
           sudo rm -rf "$CACHEDIR/$FILE"
       done
    else
       echo "(**) cache in $CACHEDIR is empty."
    fi
else
    if sudo [ -f "$CACHEDIR" ]; then
        # replace a cache file with a directory
        echo "(WW) $CACHEDIR is a file."
        echo "---- removing $CACHEDIR."
        sudo rm -r "$CACHEDIR"
    else
        echo "(WW) cache directory $CACHEDIR not found."
    fi

    # create new cache directory and assign rights
    echo "---- creating cache director $CACHEDIR."
    sudo mkdir "$CACHEDIR"
    sudo chown $QT_USER:users $CACHEDIR
    sudo chmod 700 $CACHEDIR
fi
