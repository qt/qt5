#!/usr/bin/env bash

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 9.1.0 50 3953fa0d34a467630088d2a43603f74a36a80468 ded538076858926d361af790d59c1f8440dd29b2
