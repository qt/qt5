#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

set -ex

case ${BASH_SOURCE[0]} in
    */linux/*) SERVER_PATH="${BASH_SOURCE[0]%/linux/*}/shared/testserver" ;;
    */*) SERVER_PATH="${BASH_SOURCE[0]%/*}/../shared/testserver" ;;
    *) SERVER_PATH="../shared/testserver" ;;
esac

# testserver shared scripts
source "$SERVER_PATH/testserver_util.sh"

# Using SHA-1 of each server context as the tag of docker images. A tag labels a
# specific image version. It is used by docker compose file (docker-compose.yml)
# to launch the corresponding docker containers. If one of the server contexts
# (./apache2, ./danted, ...) gets changes, all the related compose files in
# qtbase should be updated as well.

source "$SERVER_PATH/settings.sh"

for server in $testserver
do
    context="$SERVER_PATH/$server"
    # Sort files by their SHA-1 and use the accumulated result as the TAG
    sudo docker build -t qt-test-server-$server:$(sha1tree $context) $context
done

sudo docker images
