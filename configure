#! /bin/sh
#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the build tools of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:GPL-EXCEPT$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 3 as published by the Free Software
## Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

srcpath=`dirname $0`
srcpath=`(cd "$srcpath"; pwd)`
configure=$srcpath/qtbase/configure
if [ ! -e "$configure" ]; then
    echo "$configure not found. Did you forget to run \"init-repository\"?" >&2
    exit 1
fi

mkdir -p qtbase || exit

echo "+ cd qtbase"
cd qtbase || exit

echo "+ $configure -top-level $@"
exec "$configure" -top-level "$@"
