#!/usr/bin/env bash


# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools

# TODO audit and cache this file locally, see QTQAINFRA-3134
curl -L -o /tmp/homebrew_install  https://raw.githubusercontent.com/Homebrew/install/master/install

/usr/bin/ruby /tmp/homebrew_install  </dev/null

brew update
