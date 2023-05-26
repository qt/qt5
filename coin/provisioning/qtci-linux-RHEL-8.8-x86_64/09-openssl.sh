#!/usr/bin/env bash

set -ex

# Required by Rhel source build
sudo yum -y install perl-IPC-Cmd

"$(dirname "$0")/../common/unix/install-openssl.sh" "linux"
