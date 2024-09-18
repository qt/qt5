#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
set -ex

# This script will install up-to-date google Chrome needed for Webassembly auto tests.

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

chromeVersion="chrome-for-testing-115"
sha="7242ece1055bdbf503527f8e87c4b5da37c3c60e"
chromeUrl="https://ci-files01-hki.ci.qt.io/input/wasm/chrome/${chromeVersion}.tar.gz"
target="/tmp/chrome-for-testing-115.tar.gz"

DownloadURL "$chromeUrl" "" "$sha" "$target"
sudo tar -xzf "$target" -C "${HOME}"
sudo rm -f "$target"

SetEnvVar "BROWSER_FOR_WASM" "${HOME}/${chromeVersion}/chrome"
SetEnvVar "CHROMEDRIVER_PATH" "${HOME}/${chromeVersion}/chromedriver"
