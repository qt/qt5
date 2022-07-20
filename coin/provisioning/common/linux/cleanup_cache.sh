#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

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
    exit 0;
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
       FILES=`sudo ls -A1 $CACHEDIR`
       while read FILE;
           do
           echo "--- rm -rf $FILE"
           sudo rm -rf "$CACHEDIR/$FILE"
       done <<< $FILES
    else
       echo "(**) cache in $CACHEDIR is empty."
    fi
else
    if sudo [ -f "$CACHEDIR" ]; then
        # replace a cache file with a directory
        echo "(WW) $CACHEDIR is a file."
        echo "---- removing $CACHEDIR."
        sudo rm -rf "$CACHEDIR"
    else
        echo "(WW) cache directory $CACHEDIR not found."
    fi

    # create new cache directory and assign rights
    echo "---- creating cache director $CACHEDIR."
    sudo mkdir "$CACHEDIR"
    sudo chown $QT_USER:users $CACHEDIR
    sudo chmod 700 $CACHEDIR
fi
