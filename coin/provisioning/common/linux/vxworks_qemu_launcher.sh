#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Launch a single VxWorks QEMU emulator instance.
#
# Usage: vxworks_qemu_launcher.sh <arm|intel> [instance-id]
#
# Multiple instances are run in parallel to speed up the autotest run. Each
# instance gets its own tap device, guest IP, MAC address, serial FIFO pair,
# QEMU log and (for the TCG-based ARM emulator) a dedicated set of host CPU
# cores. Instance 0 keeps the historical addresses so a single-instance run
# behaves exactly as before.

[ $# -ge 1 ] || echo "Supply parameter which emulator to start <arm|intel> [instance-id]"
TYPE=$1
INSTANCE=${2:-0}

# Per-instance identifiers. Instance 0 == the original single-emulator layout.
TAP="tap${INSTANCE}"
GUEST_IP="172.31.1.$((10 + INSTANCE))"
MAC=$(printf '52:54:00:12:34:%02x' "$INSTANCE")
PIPE="/tmp/guest${INSTANCE}"
QEMU_LOG_PATH="/home/qt/work/vxworks_qemu_log_${INSTANCE}.txt"

# Per-instance SSH target: same user as VXWORKS_SSH, but the instance's IP.
if [[ "$VXWORKS_SSH" == *"@"* ]]; then
    SSH_TARGET="${VXWORKS_SSH%@*}@${GUEST_IP}"
else
    SSH_TARGET="${GUEST_IP}"
fi

# Host bridge and per-instance tap setup. Serialized across parallel launches
# and made idempotent so concurrent instances don't race on the shared bridge.
exec 9>"/tmp/vxworks_qemu_host_setup.lock"
flock 9
NFS_CONF_MARKER="# VxWorks QEMU NFS settings (added by vxworks_qemu_launcher.sh)"
# Persist the sysctl settings so they survive the reboot between the build
# and test phases, then apply them to the running kernel as well.
SYSCTL_CONF="/etc/sysctl.d/90-vxworks-qemu.conf"
if [ ! -f "$SYSCTL_CONF" ]; then
    sudo tee "$SYSCTL_CONF" >/dev/null <<'EOF'
# VxWorks QEMU network settings (added by vxworks_qemu_launcher.sh)
net.core.rmem_max=8388608
net.core.rmem_default=8388608
net.core.wmem_max=8388608
net.core.wmem_default=8388608
net.ipv4.ipfrag_high_thresh=16777216
net.ipv4.ipfrag_low_thresh=12582912
EOF
fi
sudo sysctl -q -p "$SYSCTL_CONF"

if ! grep -qF "$NFS_CONF_MARKER" /etc/nfs.conf; then
    # Configure NFS for UDP traffic
    sudo bash -c "echo -e '\n${NFS_CONF_MARKER}\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e '[nfsd]\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'threads=32\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'udp=y\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'tcp=n\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'vers2=n\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'vers3=y\n' >> /etc/nfs.conf"
    sudo bash -c "echo -e 'vers4=n\n' >> /etc/nfs.conf"
    # Setup NFS exports that are needed by VxWorks qemu
    sudo bash -c "echo '/home/qt/work 172.31.1.10/24(rw,async,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"
    sudo bash -c "echo '/opt/fsl_imx6_2_0_6_3_VSB 172.31.1.10/24(rw,async,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"
    sudo bash -c "echo '/opt/itl_generic_skylake_VSB 172.31.1.10/24(rw,async,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"
    # Restart NFS server
    sudo exportfs -ra
    sudo systemctl restart nfs-server
fi

# Setup bridge if not exist for VxWorks QEMU
if ! ip link show br0 >/dev/null 2>&1; then
    sudo brctl addbr br0
    sudo brctl stp br0 off
    sudo ifconfig br0 172.31.1.1 netmask 255.255.255.0 promisc up
fi
if ! ip link show "${TAP}" >/dev/null 2>&1; then
    sudo tunctl -u qt -t "${TAP}"
    sudo ifconfig "${TAP}" promisc up
    sudo brctl addif br0 "${TAP}"
fi
exec 9>&-

if [ "$TYPE" = "arm" ] || [ "$TYPE" = "" ]; then
    $VXWORKS_QEMU/bin/qemu-system-arm \
        -machine sabrelite \
        -smp 2 \
        -m 3G \
        -nographic \
        -monitor none \
        -serial null \
        -serial pipe:${PIPE} \
        -kernel /opt/fsl_imx6_2_0_6_3_VIP_QEMU/default/uVxWorks \
        -dtb /opt/fsl_imx6_2_0_6_3_VIP_QEMU/default/imx6q-sabrelite.dtb \
        -append "enet(0,0)host:vxWorks h=172.31.1.1 g=172.31.1.1 e=${GUEST_IP} u=target pw=vxTarget s=/romfs/startup_script.txt" \
        -rtc base=localtime,clock=rt \
        -icount sleep=off \
        -nic "tap,ifname=${TAP},script=no,mac=${MAC}" >"${QEMU_LOG_PATH}" 2>&1 &
elif [ "$TYPE" = "intel" ]; then
    $VXWORKS_QEMU/bin/qemu-system-x86_64 \
        -M q35 \
        -smp 4 \
        -m 15G \
        -cpu "Skylake-Client" \
        -enable-kvm \
        -monitor none \
        -nographic \
        -serial null \
        -serial pipe:${PIPE} \
        -kernel "/opt/itl_generic_skylake_VIP_QEMU/default/vxWorks" \
        -append "sysbootline:gei(0,0)host:vxWorks h=172.31.1.1 g=172.31.1.1 e=${GUEST_IP} u=target pw=vxTarget s=/romfs/startup_script.txt" \
        -nic "tap,ifname=${TAP},script=no,downscript=no,mac=${MAC}" >"${QEMU_LOG_PATH}" 2>&1 &
fi
QEMU_PID=$!

# The launcher is also re-invoked from inside the ctest environment when
# coin_vxworks_qemu_runner.sh restarts a wedged emulator. That environment
# carries a library path with the provisioned OpenSSL, which the system ssh
# (linked against the distro OpenSSL) refuses to load ("OpenSSL version
# mismatch"), so run ssh with a clean library path. Bound each probe with a
# hard timeout as well: ConnectTimeout only limits TCP connect, and a
# half-booted guest that accepts the connection but never answers would
# otherwise stall the loop.
#
# Boot-to-ssh takes seconds on KVM x86 but 15-60s+ on TCG ARM, with a long
# tail when several instances boot in parallel (a fixed 30-try budget killed
# healthy relaunches mid-boot on qemu_armv7), so wait on a wall-clock
# deadline rather than a retry count, and give up early only when the QEMU
# process itself has died.
SSH_WAIT_SECS=${VXWORKS_SSH_WAIT_SECS:-300}
SSH_UP=0
deadline=$((SECONDS + SSH_WAIT_SECS))
while (( SECONDS < deadline ))
do
    if [[ -n "$QEMU_PID" ]] && ! kill -0 "$QEMU_PID" 2>/dev/null; then
        echo "QEMU process for instance ${INSTANCE} exited during boot"
        break
    fi
    status=$(env -u LD_LIBRARY_PATH timeout -k 5 15 \
        ssh -n -o BatchMode=yes -o HostKeyAlgorithms=+ssh-rsa \
            -o ConnectTimeout=1 "${SSH_TARGET}" echo emulator up) || true
    if [[ $status == *"emulator up"* ]] ; then
        echo "VXWORKS QEMU SSH server up (instance ${INSTANCE} @ ${GUEST_IP})"
        SSH_UP=1
        break
    else
        echo "Waiting VXWORKS QEMU SSH server (instance ${INSTANCE} @ ${GUEST_IP})"
        sleep 1
    fi
done

# Do not report success for an instance whose SSH server never came up: the
# caller would go on to source the test script on a guest in an unknown
# state. Exit non-zero so the testrunner's restart path can fail the attempt
# and let qt-testrunner retry with a clean slot.
if [[ $SSH_UP -ne 1 ]]; then
    echo "VXWORKS QEMU SSH server did not come up (instance ${INSTANCE} @ ${GUEST_IP})"
    exit 1
fi
