#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

[ -x "$(command -v realpath)" ] && FILE=$(realpath "${BASH_SOURCE[0]}") || FILE="${BASH_SOURCE[0]}"
case $FILE in
    */*) SERVER_PATH="${FILE%/*}" ;;
    *) SERVER_PATH="." ;;
esac

# Create docker virtual machine (Boot2docker)
case $1 in
    VMX) source "$SERVER_PATH/docker_machine.sh" "-d virtualbox" ;;
    Hyper-V)
        # The Hyper-v has been enabled in Windows 10. Disable checking the hardware virtualization.
        source "$SERVER_PATH/docker_machine.sh" "-d virtualbox --virtualbox-no-vtx-check" ;;
    *) ;;
esac

# Display system-wide information of docker-engine
docker info

# Create images
"$SERVER_PATH/docker_images.sh"
