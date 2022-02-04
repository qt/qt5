#!/usr/bin/env bash

set -ex

brew install blueutil

#Disable Bluetooth
blueutil -p 0
