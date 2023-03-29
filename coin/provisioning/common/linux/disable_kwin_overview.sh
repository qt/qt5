#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e
set -f
QT_USER="qt"
CONFDIR=".config"
KWINRC="kwinrc"
KWC5=$(which kwriteconfig5)

if [ -z "$KWC5" ]; then
    echo "(WW) kwriteconfig5 script not found."
    echo "---- skipping overview disabling."
    exit 0;
fi

echo "---- ensuring window overview is disabled in kwin."

# skip if user qt does not exist
echo "---- checking user $QT_USER"
if grep -q "^$QT_USER:" /etc/passwd; then
    echo "(**) found user $QT_USER"
else
    echo "(WW) user $QT_USER not found."
    echo "---- skipping overview disabling."
    exit 0;
fi

CONFIGFILE="/home/$QT_USER/$CONFDIR/$KWINRC"

# Check kwinrc existence
echo "---- checking for kwinrc."
if [ -f "$CONFIGFILE" ]; then
   echo "(**) found kwinrc at $CONFIGFILE. Disabling overview."

   $KWC5 --file "$CONFIGFILE" --group Effect-windowview --key BorderActivateAll "9"
   $KWC5 --file "$CONFIGFILE" --group Plugins --key windowOverview "false"

else
    echo "(WW) no kwinrc found at $CONFIGFILE."
    echo "(WW) exiting."
fi
