#!/usr/bin/env bash

set -ex

# This will disable fstrim. The fstrim.timer is scheduled to activate the fstrim.service
sudo systemctl stop fstrim.timer
sudo systemctl disable fstrim.timer
