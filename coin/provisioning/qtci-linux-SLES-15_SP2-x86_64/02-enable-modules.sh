#!/usr/bin/env bash

set -ex

sudo curl http://repo-clones.ci.qt.io:8081/tools/rmt-client-setup --output rmt-client-setup
sudo chmod 755 rmt-client-setup
sudo SUSEConnect --cleanup
sudo sh rmt-client-setup https://repo-clones.ci.qt.io:8082 --yes --fingerprint C9:4F:0B:81:DE:84:AF:F2:50:3E:89:B9:7F:BC:63:BB:A7:AC:BE:97

# Activate these modules
sudo SUSEConnect -p sle-module-basesystem/15.2/x86_64
sudo SUSEConnect -p sle-module-server-applications/15.2/x86_64
sudo SUSEConnect -p sle-module-desktop-applications/15.2/x86_64
sudo SUSEConnect -p sle-module-development-tools/15.2/x86_64
sudo SUSEConnect -p sle-module-python2/15.2/x86_64

sudo zypper lr -u
