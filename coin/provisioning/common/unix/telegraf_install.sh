#!/bin/bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


# This script installs telegraf and ioping and our script telegraf-ioping.sh
# to the /usr/bin directory.
#
# The reasons we don't install to /usr/local/bin are:
# 1. On SLES and RHEL, the PATH of sudo (secure_path setting in /etc/sudoers)
#    does not include /usr/local/bin.
# 2. On macOS /usr/local/bin does not even exist early in provisioning.


######################## BOILERPLATE ###########################
set -e

PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=./common.sourced.sh
source "$PROVISIONING_DIR"/common/unix/common.sourced.sh
# shellcheck source=./DownloadURL.sh
source "$PROVISIONING_DIR"/common/unix/DownloadURL.sh

is_script_executed telegraf_install.sh \
    || fatal "Script telegraf_install.sh should be executed, not sourced"

################################################################


if [ "$PROVISIONING_OS" = linux ]
then ioping_sha256=259abf04bcb84f4126ff97c04b6651e1cf5ea6d8a9ff364c769a26c95b6eeb44
else ioping_sha256=55de6a2f1a5343e0ce8df31d82d47a9e79c7e612edbc6dfb39b5fc6fb358b2e3
fi

DownloadURL "http://ci-files01-hki.ci.qt.io/input/ioping/ioping.${PROVISIONING_OS}-${PROVISIONING_ARCH}" \
    '' "$ioping_sha256" ioping
$CMD_INSTALL -m 755 ./ioping /usr/bin/
rm -f ioping

# 2. Install custom ioping monitoring script
$CMD_INSTALL -m 755 "$PROVISIONING_DIR"/common/shared/telegraf/telegraf-ioping.sh /usr/bin/

# 3. Download and install telegraf

if [ "$PROVISIONING_OS" = macos ]
then os=darwin
else os=linux
fi

if [ "$PROVISIONING_ARCH" = x86 ]
then arch=i386
else arch=amd64
fi

package_filename=telegraf-1.12.6_${os}_${arch}.tar.gz
package_sha256_list="$PROVISIONING_DIR"/common/shared/telegraf/telegraf_packages.sha256.txt
package_sha256=$(sed -n "s/.*$package_filename *//p" "$package_sha256_list")

DownloadURL \
    http://ci-files01-hki.ci.qt.io/input/telegraf/"$package_filename" \
    https://dl.influxdata.com/telegraf/releases/"$package_filename" \
    "$package_sha256" \
    telegraf.tar.gz

tar -xzf ./telegraf.tar.gz -C /tmp
telegraf_binary=$(find /tmp/telegraf* -name telegraf -type f | grep /bin/ | head -1)
$CMD_INSTALL -m 755 "$telegraf_binary" /usr/bin/
rm -rf /tmp/telegraf*

# 4. Edit config file with passwords
"$PROVISIONING_DIR"/common/unix/telegraf_password.sh

# 5. Start telegraf in background (-b) and with retaining the environment (-E)
#    in order to report as hostname = $COIN_UNIQUE_JOB_ID.
/usr/bin/sudo -b -E telegraf --config /etc/telegraf-coin.conf >/dev/null 2>&1

echo DONE: "Installed and started telegraf: $package_filename"
