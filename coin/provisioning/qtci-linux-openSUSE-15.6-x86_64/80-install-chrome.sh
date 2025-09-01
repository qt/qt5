#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.

# This script will install up-to-date google Chrome needed for Webassembly auto tests.

# problems:
#  The jspi browser require --enable-unsafe-swiftshader to work, the original browser don't
#  Running the original browser after the jspi browser causes it to crash unless
#  we make sure the cachedir is different.

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

# DownloadURL uses functions with exit status
set +ex

function Install {
    sha=$1
    cached=$2
    official=$3
    home=$4
    target=$5

    if [ -z "$home" ]
    then
        echo "No home"
        exit 1
    fi

    if [ -z "$target" ]
    then
        echo "No target"
        exit 1
    fi

    cachedUrl="https://ci-files01-hki.ci.qt.io/input/wasm/${cached}"
    officialUrl="https://storage.googleapis.com/chrome-for-testing-public/${official}"
    tmp="/tmp/${sha}.zip"

    if ! DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$tmp"
    then
        echo "Download failed"
        exit 1
    fi

    sudo rm -rf "${home}/${target}"
    if ! unzip -q "$tmp" -d "${home}"
    then
        echo "Unzip failed"
        exit 1
    fi
    rm "$tmp"
}

Install \
    "006d8e0438980d5ca8809af6f036e2b802b13cc8" \
    "chrome/chrome-for-testing-131.zip" \
    "131.0.6778.204/linux64/chrome-linux64.zip" \
    "${HOME}" \
    "chrome-linux64"

Install \
    "53007a6778c4ba25763d066f12c598b982e72f74" \
    "chromedriver/chrome-for-testing-131.zip" \
    "131.0.6778.204/linux64/chromedriver-linux64.zip" \
    "${HOME}" \
    "chromedriver-linux64"

Install \
    "9743a66a4427711e5b0cf1d569c1b893eab3c123" \
    "chrome/chrome-for-testing-139.zip" \
    "139.0.7258.138/linux64/chrome-linux64.zip" \
    "${HOME}/jspi" \
    "chrome-linux64"

Install \
    "874a7870150ed0b20908ae77a5bd10d8cd5dea11" \
    "chromedriver/chrome-for-testing-139.zip" \
    "139.0.7258.138/linux64/chromedriver-linux64.zip" \
    "${HOME}/jspi" \
    "chromedriver-linux64"

chromePath="${HOME}/chrome-linux64/"
chromeDriverPath="${HOME}/chromedriver-linux64/"
chromeJspiPath="${HOME}/jspi/chrome-linux64/"
chromeJspiDriverPath="${HOME}/jspi/chromedriver-linux64/"

cp ${chromeDriverPath}chromedriver ${chromePath}
cp ${chromeJspiDriverPath}chromedriver ${chromeJspiPath}

SetEnvVar "BROWSER_FOR_WASM" "${chromePath}chrome"
SetEnvVar "CHROMEDRIVER_PATH" "${chromePath}chromedriver"

SetEnvVar "WASM_BROWSER_JSPI"                "${chromeJspiPath}chrome"
SetEnvVar "WASM_BROWSER_JSPI_ARGS"           "\"--headless --password-store=basic --enable-unsafe-swiftshader --user-data-dir=${HOME}/.cache/jspi\""
SetEnvVar "WASM_CHROMEDRIVER_PATH_JSPI"      "${chromeJspiPath}chromedriver"
SetEnvVar "WASM_CHROMEDRIVER_PATH_JSPI_ARGS" "\"--headless --password-store=basic --enable-unsafe-swiftshader --user-data-dir=${HOME}/.cache/jspi\""
