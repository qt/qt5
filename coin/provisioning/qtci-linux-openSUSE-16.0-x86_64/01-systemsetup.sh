#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/shared/network_test_server_ip.txt
source "$BASEDIR/../common/shared/network_test_server_ip.txt"
# shellcheck source=../common/unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# https://bugzilla.opensuse.org/show_bug.cgi?id=1032027
sudo btrfs quota disable /

sed -i '$ a\[Daemon\]\nAutolock=false\nLockOnResume=false' ~/.config/kscreenlockerrc

sudo sed -i 's|GRUB_TIMEOUT=8|GRUB_TIMEOUT=0|g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

"$BASEDIR/../common/linux/configure-gnome-shell.sh"

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts
echo "Set DISPLAY"
echo 'export DISPLAY=":0"' >> ~/.bashrc
#echo "Disabling file indexing."
#sudo balooctl disable           # Not available, no longer installed by default

sudo systemctl stop packagekit
sudo systemctl disable packagekit
sudo systemctl mask packagekit
while sudo fuser /usr/lib/packagekitd >/dev/null 2>&1 ; do
    echo "Waiting for PackageKit to finish..."
    sleep 0.5
done
#echo "Disabling update notifications"
sudo zypper -nq remove discover6-notifier

# shellcheck disable=SC2031
if [ "$http_proxy" != "" ]; then
    sudo sed -i 's/PROXY_ENABLED=\"no\"/PROXY_ENABLED=\"yes\"/' /etc/sysconfig/proxy
    sudo sed -i "s|HTTP_PROXY=\".*\"|HTTP_PROXY=\"$proxy\"|" /etc/sysconfig/proxy
fi

echo "Set CA certificate env variables for GIT and CURL"
ca_path="/var/lib/ca-certificates/openssl/"
ca_bundle="/var/lib/ca-certificates/ca-bundle.pem"
SetEnvVar "GIT_SSL_CAPATH" "$ca_path"
SetEnvVar "CURL_CA_BUNDLE" "$ca_bundle"
