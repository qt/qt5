#!/bin/bash
#Copyright (C) 2025 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools

set -e

INSTALLTYPE="$1"
VERSION="$2"
CHECKSUM="$3"

DEFAULT_PKG_VERSION="4.4.21"
DEFAULT_PKG_VERSION_CHECKSUM="cd83c4123d5db7d07eb3042f1c785ed7f599183c5c542040bc6abfa722583861"
DEFAULT_GIT_VERSION="deb02e27d99fd2cb27ae16760e3a5272b612fded"
DEFAULT_GIT_VERSION_CHECKSUM="a30b9fbf0d5c2cff3eb1d0643cceee30d8ba6ea1bb7bcabf60d3188bd62e6ba6"

source "$(dirname "$0")"/../../common/unix/DownloadURL.sh
source "$(dirname "$0")"/../../common/unix/SetEnvVar.sh

installPkg() {
    if [ "$VERSION" == "" ]; then
        VERSION="$DEFAULT_PKG_VERSION"
        CHECKSUM="$DEFAULT_PKG_VERSION_CHECKSUM"
    fi
    DownloadURL  \
        "http://ci-files01-hki.ci.qt.io/input/mac/homebrew/$VERSION/Homebrew-$VERSION.pkg"  \
        "https://github.com/Homebrew/brew/releases/download/$VERSION/Homebrew-$VERSION.pkg"  \
        "$CHECKSUM" \
        "/tmp/Homebrew-$VERSION.pkg"

    sudo installer -pkg "/tmp/Homebrew-$VERSION.pkg" -target /

    echo "Homebrew = $VERSION" >> ~/versions.txt
}

installGit() {
    if [ "$VERSION" == "" ]; then
        VERSION="$DEFAULT_GIT_VERSION"
        CHECKSUM="$DEFAULT_GIT_VERSION_CHECKSUM"
    fi

    export HOMEBREW_BREW_GIT_REMOTE="https://git.intra.qt.io/external-repository-mirrors/homebrew/brew.git"  # put your Git mirror of Homebrew/brew here
    export HOMEBREW_CORE_GIT_REMOTE="https://git.intra.qt.io/external-repository-mirrors/homebrew/homebrew-core.git"  # put your Git mirror of Homebrew/homebrew-core here
    DownloadURL  \
        "https://git.intra.qt.io/external-repository-mirrors/homebrew/install/-/raw/$VERSION/install.sh" \
        "https://git.intra.qt.io/external-repository-mirrors/homebrew/install/-/raw/$VERSION/install.sh" \
        $CHECKSUM  \
        /tmp/homebrew_install.sh

    DownloadURL "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "aae58d00d0a1b179a09f21cfc67f9d16fb95ff36" "/Users/qt/pw"
    { pw=$(cat "/Users/qt/pw"); } 2> /dev/null
    sudo chmod 755 /tmp/homebrew_install.sh
    { (echo "$pw" | /tmp/homebrew_install.sh); } 2> /dev/null
    rm -f "/Users/qt/pw"
}

if [ "$INSTALLTYPE" == "GIT" ]; then
    installGit
else
    installPkg
fi

ARCH_TYPE=$(arch)
# Add homebrew to PATH
if [ "$ARCH_TYPE" == "arm64" ]; then
    SetEnvVar "PATH" "/opt/homebrew/bin:\$PATH"
else
    SetEnvVar "PATH" "/usr/local/bin:\$PATH"
fi

# Disable non-ascii output for homebrew to make logs more readable
SetEnvVar "HOMEBREW_NO_COLOR" "1"
SetEnvVar "HOMEBREW_NO_EMOJI" "1"
SetEnvVar "HOMEBREW_NO_ENV_HINTS" "1"
