#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
set -ex

# This script will install up-to-date google Chrome needed for Webassembly auto tests.

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

chromeVersion="chrome-for-testing-131"
sha="006d8e0438980d5ca8809af6f036e2b802b13cc8"
cachedChromeUrl="https://ci-files01-hki.ci.qt.io/input/wasm/chrome/${chromeVersion}.zip"
officialChromeUrl="https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.204/linux64/chrome-linux64.zip"
target="/tmp/${chromeVersion}.zip"

DownloadURL "$cachedChromeUrl" "$officialChromeUrl" "$sha" "$target"
sudo unzip -q "$target" -d "${HOME}"
sudo rm -f "$target"
chromePath="${HOME}/chrome-linux64/chrome"
SetEnvVar "BROWSER_FOR_WASM" "${chromePath}"
