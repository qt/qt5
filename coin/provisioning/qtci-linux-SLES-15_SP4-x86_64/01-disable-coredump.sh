#!/usr/bin/env bash

set -ex

sudo chkconfig kdump off
sudo sed -i 's/#Storage=external/Storage=none/g' /etc/systemd/coredump.conf
