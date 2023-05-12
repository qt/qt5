#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script sets the macOS locale to UTF-8
set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
SetEnvVar "LANG" "en_US.UTF-8"

# The following settings match the "United States" region default
defaults write -globalDomain AppleLocale "en_US"
defaults write -globalDomain AppleLanguages "(en)"
defaults write -globalDomain AppleMeasurementUnits "Inches"
defaults write -globalDomain AppleTemperatureUnit "Fahrenheit"
defaults write -globalDomain AppleMetricUnits -bool false
