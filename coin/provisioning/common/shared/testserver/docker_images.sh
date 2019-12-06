#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

[ -x "$(command -v realpath)" ] && FILE=$(realpath ${BASH_SOURCE[0]}) || FILE=${BASH_SOURCE[0]}
case $FILE in
    */*) SERVER_PATH="${FILE%/*}" ;;
    *) SERVER_PATH="." ;;
esac

# Sort files by their SHA-1, and then return the accumulated result
sha1tree () {
    # For example, macOS doesn't install sha1sum by default. In such case, it uses shasum instead.
    [ -x "$(command -v sha1sum)" ] || SHASUM=shasum

    find "$@" -type f -print0 | \
        xargs -0 ${SHASUM-sha1sum} | cut -d ' ' -f 1 | \
        sort | ${SHASUM-sha1sum} | cut -d ' ' -f 1
}

# A tag labels a specific image version. In the docker compose file
# (docker-compose.yml) that launches the containers, the tag used is
# "latest". Here the images are also tagged with the SHA1 of each server
# context, so if needed we can modify docker-compose.yml to launch a very
# specific image, thus providing a way to stage backwards-incompatible changes
# across repositories.

source "$SERVER_PATH/settings.sh"

for server in $testserver
do
    context="$SERVER_PATH/$server"
    tag=$(sha1tree $context)
    docker build -t qt-test-server-$server:$tag -t qt-test-server-$server:latest  $context
done

docker images
