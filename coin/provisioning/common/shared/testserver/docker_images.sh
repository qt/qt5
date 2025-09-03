#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

PROVISIONING_DIR="$(dirname "$0")/../../../"
# shellcheck source=../../../common/unix/common.sourced.sh
source "$PROVISIONING_DIR"/common/unix/common.sourced.sh
# shellcheck source=../../../common/unix/DownloadURL.sh
source "$PROVISIONING_DIR"/common/unix/DownloadURL.sh

# Sort files by their SHA-1, and then return the accumulated result
sha1tree () {
    # For example, macOS doesn't install sha1sum by default. In such case, it uses shasum instead.
    [ -x "$(command -v sha1sum)" ] || SHASUM=shasum

    find "$@" -type f -print0 | \
        xargs -0 "${SHASUM-sha1sum}" | cut -d ' ' -f 1 | \
        sort | "${SHASUM-sha1sum}" | cut -d ' ' -f 1
}


SERVER_PATH="$PROVISIONING_DIR/common/shared/testserver"

source "$SERVER_PATH/settings.sh"


# Download all necessary dependencies outside of the dockerfiles, so that we
# can use provisioning functionality for cached and verified downloads. In the
# dockerfiles we just do COPY to put them where needed.

echo 'Downloading support files for the docker images'

DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/docker/rfc3252.txt  \
    https://tools.ietf.org/rfc/rfc3252.txt  \
    50c323dedce95e4fdc2db35cd1b8ebf9d74711bf5296ef438b88d186d7dd082d
cp rfc3252.txt "$SERVER_PATH/vsftpd/"
cp rfc3252.txt "$SERVER_PATH/apache2/"

DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/docker/dante-server_1.4.1-1_amd64.deb  \
    http://ppa.launchpad.net/dajhorn/dante/ubuntu/pool/main/d/dante/dante-server_1.4.1-1_amd64.deb  \
    674a06f356cebd92c64920cec38a6687650a6f880198fbbad05aaaccca5c0a21
mv dante-server_1.4.1-1_amd64.deb "$SERVER_PATH/danted/"

DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/docker/FreeCoAP-0.7.tar.gz  \
    https://github.com/keith-cullen/FreeCoAP/archive/v0.7.tar.gz  \
    fa6602e27dc8eaee6e34ff53400c0519da0c5c7cd47bf6f13acb564f52a693ee  \
    FreeCoAP-0.7.tar.gz
mv FreeCoAP-0.7.tar.gz "$SERVER_PATH/freecoap/"

# Eclipse Californium 3.8.0, requires to apply a custom patch from
# $SERVER_PATH/californium/ before usage
DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/docker/californium-3.8.0.tar.gz \
    https://github.com/eclipse-californium/californium/archive/refs/tags/3.8.0.tar.gz \
    24f8ca393f26c922739462e4586b8ced1ff75f99bfa795defa34a967b5a4a5a0  \
    californium-3.8.0.tar.gz
mv californium-3.8.0.tar.gz "$SERVER_PATH/californium/"
# Download cached maven dependencies for californium.
# The dependency archive is built by
# "mvn dependency:go-offline -DskipTests -Dos.detected.classifier=linux-x86_64"
# and archived from /root/.m2
DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/docker/californium-m2deps-3.8.0.tar.gz \
    http://ci-files01-hki.ci.qt.io/input/docker/californium-m2deps-3.8.0.tar.gz \
    e2fade7dde3cca02bb910eed99a5d8b5cb8ff945240c65bf06ce50411d70d3f2  \
    californium-m2deps-3.8.0.tar.gz
mv californium-m2deps-3.8.0.tar.gz "$SERVER_PATH/californium/"


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
    tag=$(sha1tree "$context")
    docker build -t "qt-test-server-$server:latest"  \
                 -t "qt-test-server-$server:$tag"    \
        "$context"
done

docker images
