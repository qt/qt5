#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Setup bridge if not exist for VxWorks QEMU
if ! ip link show br0 >/dev/null 2>&1; then
    sudo brctl addbr br0
    sudo brctl stp br0 off
    sudo ifconfig br0 172.31.1.1 netmask 255.255.255.0 promisc up
    sudo tunctl -u qt -t tap0
    sudo ifconfig tap0 promisc up
    sudo brctl addif br0 tap0
fi

[ $# -eq 1 ] || echo "Supply parameter which emulator to start <arm|intel>"
TYPE=$1

QEMU_LOG_PATH="/home/qt/work/vxworks_qemu_log.txt"
if [ "$TYPE" = "arm" ] || [ "$TYPE" = "" ]; then
    $VXWORKS_QEMU/bin/qemu-system-arm \
        -machine sabrelite \
        -smp 4 \
        -m 1G \
        -nographic \
        -monitor none \
        -serial null \
        -serial pipe:/tmp/guest \
        -kernel /opt/fsl_imx6_2_0_6_2_VIP_QEMU/default/uVxWorks \
        -dtb /opt/fsl_imx6_2_0_6_2_VIP_QEMU/default/imx6q-sabrelite.dtb \
        -append "enet(0,0)host:vxWorks h=172.31.1.1 g=172.31.1.1 e=172.31.1.10 u=target pw=vxTarget s=/romfs/startup_script.txt" \
        -nic "tap,ifname=tap0,script=no" >"${QEMU_LOG_PATH}" 2>&1 &
elif [ "$TYPE" = "intel" ]; then
    $VXWORKS_QEMU/bin/qemu-system-x86_64 \
        -M q35 \
        -smp 8 \
        -m 8G \
        -cpu "Skylake-Client" \
        -monitor none \
        -nographic \
        -serial null \
        -serial pipe:/tmp/guest \
        -kernel "/opt/itl_generic_skylake_VIP_QEMU/default/vxWorks" \
        -append "sysbootline:gei(0,0)host:vxWorks h=172.31.1.1 g=172.31.1.1 e=172.31.1.10 u=target pw=vxTarget s=/romfs/startup_script.txt" \
        -nic tap,ifname=tap0,script=no,downscript=no >"${QEMU_LOG_PATH}" 2>&1 &
fi

for _ in $(seq 30)
do
    status=$(ssh -o BatchMode=yes -o HostKeyAlgorithms=+ssh-rsa -o ConnectTimeout=1 "${VXWORKS_SSH}" echo emulator up) || true
    if [[ $status == *"emulator up"* ]] ; then
        echo "VXWORKS QEMU SSH server up"
        break
    else
        echo "Waiting VXWORKS QEMU SSH server"
        sleep 1
    fi
done
