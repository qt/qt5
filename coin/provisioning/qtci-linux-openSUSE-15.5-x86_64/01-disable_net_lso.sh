#!/bin/sh

echo "ethtool -K \${DEVICE_IFACE} tso off" | sudo tee -a /etc/NetworkManager/dispatcher.d/net_tso_off
sudo chmod +x /etc/NetworkManager/dispatcher.d/net_tso_off
