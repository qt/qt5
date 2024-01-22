#!/bin/sh
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


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
    [ "$(basename "$(echo "$0" | sed s/^-//)")" = "$1" ]
}


is_script_executed  common.sourced.sh  \
    && fatal "Script common.sourced.sh should always be sourced, not executed"


_detect_linux_OS_ID () {
    if [ -f /etc/os-release ]
    then
        # shellcheck source=/dev/null
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

    [ -z "$PROVISIONING_DIR" ]  \
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
        aarch64|arm64)PROVISIONING_ARCH=arm64 ;;
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
