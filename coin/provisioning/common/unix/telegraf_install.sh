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
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh

. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh

is_script_executed telegraf_install.sh  \
    || fatal "Script telegraf_install.sh should be executed, not sourced"

################################################################


[ "$PROVISIONING_OS" = linux ]  \
    && ioping_sha256=259abf04bcb84f4126ff97c04b6651e1cf5ea6d8a9ff364c769a26c95b6eeb44  \
    || ioping_sha256=55de6a2f1a5343e0ce8df31d82d47a9e79c7e612edbc6dfb39b5fc6fb358b2e3
DownloadURL "http://ci-files01-hki.intra.qt.io/input/ioping/ioping.${PROVISIONING_OS}-${PROVISIONING_ARCH}"  \
    ''  "$ioping_sha256"  ioping
$CMD_INSTALL -m 755 ./ioping /usr/bin/
rm -f ioping

# 2. Install custom ioping monitoring script
$CMD_INSTALL -m 755  "$PROVISIONING_DIR"/common/shared/telegraf/telegraf-ioping.sh  /usr/bin/

# 3. Download and install telegraf

[ x"$PROVISIONING_OS"   = xmacos ] && os=darwin || os=linux
[ x"$PROVISIONING_ARCH" = xx86   ] && arch=i386 || arch=amd64
package_filename=telegraf-1.12.6_${os}_${arch}.tar.gz
package_sha256_list="$PROVISIONING_DIR"/common/shared/telegraf/telegraf_packages.sha256.txt
package_sha256=$(sed -n "s/.*$package_filename *//p" "$package_sha256_list")

DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/telegraf/"$package_filename"  \
    https://dl.influxdata.com/telegraf/releases/"$package_filename"  \
    "$package_sha256"  \
    telegraf.tar.gz

tar -xzf ./telegraf.tar.gz -C /tmp
telegraf_binary=$(find /tmp/telegraf* -name telegraf -type f | grep /bin/ | head -1)
$CMD_INSTALL -m 755  "$telegraf_binary"  /usr/bin/
rm -rf /tmp/telegraf*

# 4. Edit config file with passwords
"$PROVISIONING_DIR"/common/unix/telegraf_password.sh

# 5. Start telegraf in background (-b) and with retaining the environment (-E)
#    in order to report as hostname = $COIN_UNIQUE_JOB_ID.
/usr/bin/sudo -b -E telegraf --config /etc/telegraf-coin.conf >/dev/null 2>&1

echo DONE: "Installed and started telegraf: $package_filename"
