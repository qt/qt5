#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

TestMachine='qt-test-server'

# Deploy docker virtual machine (Boot2Docker) into VirtualBox only if it doesn't exist
if [ -z "$(docker-machine ls -q --filter "name=$TestMachine")" ]
then
    docker-machine create "$@" "$TestMachine"
    docker-machine ip "$TestMachine"
else
    # Otherwise, start the docker machine and update with new TLS certificates.
    docker-machine start "$TestMachine" && docker-machine regenerate-certs -f "$TestMachine"
fi

# Switch the docker engine to $TestMachine
eval "$(docker-machine env "$TestMachine")"

docker-machine ls
