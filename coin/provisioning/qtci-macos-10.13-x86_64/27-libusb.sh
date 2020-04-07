#!/usr/bin/env bash
# Install libusb

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/macos/libusb.sh"
