#!/bin/sh

echo "ETHTOOL_OPTS='-K \${DEVICE} tso off'" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-Wired_connection_1
