#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Setup bridge if not exist for VxWorks QEMU
if ! ip link show br0 >/dev/null 2>&1; then
    sudo brctl addbr br0
    sudo brctl stp br0 off
    sudo ifconfig br0 10.0.2.1 netmask 255.255.255.0 promisc up
    sudo tunctl -u qt -t tap0
    sudo ifconfig tap0 promisc up
    sudo brctl addif br0 tap0
fi

QEMU_LOG_PATH="/home/qt/work/vxworks_qemu_log.txt"
qemu-system-arm \
    -machine sabrelite \
    -smp 4 \
    -m 1G \
    -nographic \
    -monitor none \
    -serial null \
    -serial stdio \
    -kernel /opt/fsl_imx6_2_0_6_2_VIP_QEMU/default/uVxWorks \
    -dtb /opt/fsl_imx6_2_0_6_2_VIP_QEMU/default/imx6q-sabrelite.dtb \
    -append "enet(0,0)host:vxWorks h=10.0.2.1 g=10.0.2.1 e=10.0.2.4 u=target pw=vxTarget s=/romfs/startup_script_arm.txt" \
    -nic "tap,ifname=tap0,script=no" >"${QEMU_LOG_PATH}" 2>&1 &

for counter in $(seq 30)
do
    status=$(ssh -o BatchMode=yes -o HostKeyAlgorithms=+ssh-rsa -o ConnectTimeout=1 ${VXWORKS_SSH} echo emulator up)
    if [[ $status == *"emulator up"* ]] ; then
        echo "VXWORKS QEMU SSH server up"
        break
    else
        echo "Waiting VXWORKS QEMU SSH server"
        sleep 1
    fi
done
