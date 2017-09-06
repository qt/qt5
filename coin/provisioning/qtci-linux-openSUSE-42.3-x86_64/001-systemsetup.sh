#!/bin/bash
set -e

BASEDIR=$(dirname "$0")
source $BASEDIR/../common/network_test_server_ip.txt

sed -i '$ a\[Daemon\]\nAutolock=false\nLockOnResume=false' ~/.config/kscreenlockerrc

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts
echo "Set DISPLAY"
echo 'export DISPLAY=":0"' >> ~/.bashrc

