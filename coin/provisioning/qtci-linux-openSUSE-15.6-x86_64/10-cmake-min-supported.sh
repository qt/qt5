#!/usr/bin/env bash

set -ex

"$(dirname "$0")/../common/linux/cmake_min_supported.sh"

# For testing Qt's CMake deployment API with CMake < 3.21, we need patchelf.
sudo zypper -nq install patchelf
