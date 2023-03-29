#!/bin/bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


######################## BOILERPLATE ###########################
set -e

PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=./common.sourced.sh
source "${BASH_SOURCE%/*}/common.sourced.sh"

is_script_executed telegraf_password.sh  \
    || fatal "Script telegraf_password.sh should be executed, not sourced, to avoid leaking secrets in the logs"
# Avoid leaking secrets in the logs
set +x
################################################################


# Provisioning should run even without the secrets repository
influxdb_password=$(cut -d : -f 2  ~qt/work/influxdb/coin_vms_writer.auth)  \
   || influxdb_password=no_password_provided

rm -f ~qt/work/influxdb/coin_vms_writer.auth
sed "s|COIN_VMS_WRITER_PASS|$influxdb_password|"  \
    "$PROVISIONING_DIR"/common/"$PROVISIONING_OS"/telegraf-coin.conf  \
    > .telegraf-coin.conf.final
$CMD_INSTALL -m 600 .telegraf-coin.conf.final /etc/telegraf-coin.conf
rm -f .telegraf-coin.conf.final
