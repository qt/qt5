#!/usr/bin/env bash

# Ipv6 link local becomes tentative and dadfailed if two systems has the same secret_key
# New unique secret key will be created automatically during start up.
# https://access.redhat.com/solutions/3553581
echo "Removing secret_key"
sudo rm -f "/var/lib/NetworkManager/secret_key"


