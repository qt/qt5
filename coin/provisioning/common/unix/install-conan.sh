#!/usr/bin/env bash

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install Conan
# Note! Python3 is required for Conan installation

# Install Conan to Python user install directory (typically ~./local/)
pip3 install conan --user

SetEnvVar "CONAN_REVISIONS_ENABLED" "1"
