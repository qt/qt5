#!/bin/sh
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#
# Usage: ./qt_run_all.sh [directory]
# Script to run all provisioning scripts in the current directory in alphabetical order
# for the purpose of manually provisioning a freshly installed Linux / macOS system
#
# Caution:
# - Don't copy this to or call it from a platform provisioning directory
# - It's not guaranteed that scripts are run in the exact same order as during COIN provisioning
#

set -e
DIR="${1:-.}"

DIR="$(cd "$DIR" 2>/dev/null && pwd)" || {
  echo "Error: directory not found or not accessible." >&2
  exit 1
}

echo "Running .sh files in: $DIR"

find "$DIR" -maxdepth 1 -name "*.sh" | sort | while IFS= read -r script; do
  # Skip ourselves
  [ "$(realpath "$script")" = "$(realpath "$0")" ] && continue
  echo "--- Running: $script"
  sh "$script"
  echo "------ Done: $script (exit code: $?)"
done

echo "Provisioning done."
