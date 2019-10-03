#!/bin/sh

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


######################## BOILERPLATE ###########################
set -e


PROVISIONING_DIR="$(dirname "$0")/../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh

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
