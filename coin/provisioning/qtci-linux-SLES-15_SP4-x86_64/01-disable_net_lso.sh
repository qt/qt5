#!/bin/sh

sudo mkdir -p /etc/wicked/scripts
echo "ethtool -K \$2 tso off" | sudo tee -a /etc/wicked/scripts/net_tso_off
sudo chmod 744 /etc/wicked/scripts/net_tso_off
echo "PRE_UP_SCRIPT='wicked:/etc/wicked/scripts/net_tso_off'" | sudo tee -a /etc/sysconfig/network/ifcfg-eth0
