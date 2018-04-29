#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/shared/network_test_server_ip.txt
source "$BASEDIR/../common/shared/network_test_server_ip.txt"
# shellcheck source=../common/unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"

sed -i '$ a\[Daemon\]\nAutolock=false\nLockOnResume=false' ~/.config/kscreenlockerrc

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts
echo "Set DISPLAY"
echo 'export DISPLAY=":0"' >> ~/.bashrc
echo "Disabling file indexing."
sudo balooctl disable
echo "Disable update notifications"
sudo zypper -nq remove plasma5-pk-updates

# shellcheck disable=SC2031
if [ "$http_proxy" != "" ]; then
    sudo sed -i 's/PROXY_ENABLED=\"no\"/PROXY_ENABLED=\"yes\"/' /etc/sysconfig/proxy
    sudo sed -i "s|HTTP_PROXY=\".*\"|HTTP_PROXY=\"$proxy\"|" /etc/sysconfig/proxy
fi

