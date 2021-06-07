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


# Script to be sourced from everywhere you need a common environment. Defines:
export PROVISIONING_DIR
export PROVISIONING_OS
export PROVISIONING_OS_ID
export PROVISIONING_ARCH
export CMD_PKG_INSTALL
export CMD_PKG_LOCALINSTALL
export CMD_INSTALL
export COIN_RUNS_IN_QT_COMPANY



if [ x"$IS_PROVISIONING_COMMON_SOURCED" != x ]
then
    echo "common.sourced.sh has already been sourced, re-sourcing skipped"
    return
fi

# Do not export; you want children to re-source, because they only inherit the
# variables but not the functions
IS_PROVISIONING_COMMON_SOURCED=1


fatal () {
    echo "$1" 1>&2
    if [ x"$2" != x ]
    then  exit "$2"
    else  exit
    fi
}

# Takes one argument which should be the filename of this script. Returns true
# if the script is being sourced, false if the script is being executed.
is_script_executed () {
    [ x"$(basename $(echo "$0" | sed s/^-//))" = x"$1" ]
}


is_script_executed  common.sourced.sh  \
    && fatal "Script common.sourced.sh should always be sourced, not executed"


_detect_linux_OS_ID () {
    if [ -f /etc/os-release ]
    then
        . /etc/os-release
        PROVISIONING_OS_ID="$ID"
    elif [ -f /etc/redhat-release ]
    then
         case "$(cat /etc/redhat-release)" in
             "Red Hat Enterprise Linux"*)
                 PROVISIONING_OS_ID="rhel"
                 ;;
             "CentOS Linux"*)
                 PROVISIONING_OS_ID="centos"
                 ;;
             *) fatal "Unknown string in /etc/redhat-release" ;;
         esac
    fi
}

set_common_environment () {
    # Unfortunately we can't find the provisioning directory from a sourced
    # script in a portable way
    # PROVISIONING_DIR="$(dirname "$0")/../../"

    [ x"$PROVISIONING_DIR" = x ]  \
        &&  fatal  "PROVISIONING_DIR variable needs to be set before calling set_common_environment"

    uname_s="$(uname -s)"
    case "$uname_s" in
        Linux)
            PROVISIONING_OS=linux
            _detect_linux_OS_ID
            case "$PROVISIONING_OS_ID" in
                suse|sles|opensuse*)
                    CMD_PKG_INSTALL="sudo zypper -nq install"
                    CMD_PKG_LOCALINSTALL="sudo zypper --no-gpg-checks -nq install"
                    ;;
                debian|ubuntu)
                    CMD_PKG_INSTALL="sudo apt -y install"
                    CMD_PKG_LOCALINSTALL="sudo apt -y install"
                    ;;
                rhel|centos|fedora)
                    CMD_PKG_INSTALL="sudo yum -y install"
                    CMD_PKG_LOCALINSTALL="sudo yum -y --nogpgcheck localinstall"
                    ;;
                *)  fatal "Unknown ID in /etc/os-release: $PROVISIONING_OS_ID" ;;
            esac
            ;;
        Darwin)
            PROVISIONING_OS=macos
            PROVISIONING_OS_ID=macos
            CMD_PKG_INSTALL="brew install"
            CMD_PKG_LOCALINSTALL="echo 'TODO how to install a package file on macOS'"
            ;;
        *)
            fatal "Unknown system in uname: $uname_s" 42
            ;;
    esac

    uname_m="$(uname -m)"
    case "$uname_m" in
        x86_64|amd64) PROVISIONING_ARCH=amd64 ;;
        i[3456]86)    PROVISIONING_ARCH=x86  ;;
        *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
    esac

    CMD_INSTALL="sudo install"

    COIN_RUNS_IN_QT_COMPANY=false
    if  ping -c1 repo-clones.ci.qt.io  >/dev/null 2>&1
    then
        COIN_RUNS_IN_QT_COMPANY=true
    fi

}

set_common_environment

set_dry_run () {
    if [ x"$PROVISIONING_DRY_RUN" != x ]
    then
        CMD_PKG_INSTALL="echo DRYRUN:  $CMD_PKG_INSTALL"
        CMD_PKG_LOCALINSTALL="echo DRYRUN:  $CMD_PKG_LOCALINSTALL"
        CMD_INSTALL="echo DRYRUN:  $CMD_INSTALL"
    fi
}

set_dry_run
