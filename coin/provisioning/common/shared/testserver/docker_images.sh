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

set -e


PROVISIONING_DIR="$(dirname "$0")/../../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


# Sort files by their SHA-1, and then return the accumulated result
sha1tree () {
    # For example, macOS doesn't install sha1sum by default. In such case, it uses shasum instead.
    [ -x "$(command -v sha1sum)" ] || SHASUM=shasum

    find "$@" -type f -print0 | \
        xargs -0 ${SHASUM-sha1sum} | cut -d ' ' -f 1 | \
        sort | ${SHASUM-sha1sum} | cut -d ' ' -f 1
}


SERVER_PATH="$PROVISIONING_DIR/common/shared/testserver"

. "$SERVER_PATH/settings.sh"


# Download all necessary dependencies outside of the dockerfiles, so that we
# can use provisioning functionality for cached and verified downloads. In the
# dockerfiles we just do COPY to put them where needed.

echo 'Downloading support files for the docker images'

DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/docker/rfc3252.txt  \
    https://tools.ietf.org/rfc/rfc3252.txt  \
    50c323dedce95e4fdc2db35cd1b8ebf9d74711bf5296ef438b88d186d7dd082d
cp rfc3252.txt "$SERVER_PATH/vsftpd/"
cp rfc3252.txt "$SERVER_PATH/apache2/"

DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/docker/dante-server_1.4.1-1_amd64.deb  \
    http://ppa.launchpad.net/dajhorn/dante/ubuntu/pool/main/d/dante/dante-server_1.4.1-1_amd64.deb  \
    674a06f356cebd92c64920cec38a6687650a6f880198fbbad05aaaccca5c0a21
mv dante-server_1.4.1-1_amd64.deb "$SERVER_PATH/danted/"

DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/docker/FreeCoAP-0.7.tar.gz  \
    https://github.com/keith-cullen/FreeCoAP/archive/v0.7.tar.gz  \
    fa6602e27dc8eaee6e34ff53400c0519da0c5c7cd47bf6f13acb564f52a693ee  \
    FreeCoAP-0.7.tar.gz
mv FreeCoAP-0.7.tar.gz "$SERVER_PATH/freecoap/"

# Custom fork of Eclipse Californium with changes not upstream
DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/docker/californium-secure-test-server.tar.gz  \
    https://github.com/sonakur/californium/archive/secure-test-server.tar.gz  \
    0ee7f5d4366b9e31f6d2d42e389cb7a66d2db54987b700a38a3a31e8f38a7a19  \
    californium-secure-test-server.tar.gz
mv californium-secure-test-server.tar.gz "$SERVER_PATH/californium/"


echo 'Building the docker images...'

# Build the 2 base layers: qt_ubuntu_1604, qt_ubuntu_1804.
# These are the base for all other docker images.
for image in  qt_ubuntu_16.04 qt_ubuntu_18.04
do
    docker build -t $image  \
        --build-arg  COIN_RUNS_IN_QT_COMPANY="$COIN_RUNS_IN_QT_COMPANY"  \
        "$SERVER_PATH/$image"
done


for server in $testserver
do

    # We label each docker image with `-t name:tag`.
    # A tag labels a specific image version. In the docker compose file
    # (docker-compose.yml) that launches the containers, the tag used is
    # "latest". Here the images are additionally tagged with the SHA1 of each
    # image directory (context), so that if needed we can modify
    # docker-compose.yml and modify "latest" to a SHA in order to launch a
    # very specific image, thus providing a way to stage
    # backwards-incompatible changes across repositories.

    context="$SERVER_PATH/$server"
    tag=$(sha1tree $context)
    docker build -t qt-test-server-$server:latest  \
                 -t qt-test-server-$server:$tag    \
        $context
done

docker images
