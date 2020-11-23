#!/usr/bin/env bash

set -ex

# Activate these modules
# Note! Modules'Server Applications Module 15 SP2 x86_64' & 'Server Applications Module 15 SP2 x86_64' were enabled during registrarion phase
sudo SUSEConnect -p sle-module-desktop-applications/15.2/x86_64
sudo SUSEConnect -p sle-module-development-tools/15.2/x86_64
sudo SUSEConnect --product sle-module-python2/15.2/x86_64

