#!/bin/sh
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#
# Script to run all provisioning scripts in the current directory in alphabetical order
# for the purpose of manually provisioning a freshly installed Linux / macOS system
#
# Caution:
# - Don't copy this to or call it from a platform provisioning directory
# - It's not guaranteed that scripts are run in the exact same order as during COIN provisioning
#

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [directory]

Run all *.sh provisioning scripts in the given directory (default: current
directory) in alphabetical order.

Options:
  -s, --stop-on-error   Stop at the first script that fails.
                        Default: continue and report all failures at the end.
  -h, --help            Show this help and exit.

By default this script does NOT stop on errors: every script is attempted and
failures are collected and reported in a summary at the end. The exit code is
non-zero if any script failed.
EOF
}

stop_on_error=0
DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--stop-on-error)
      stop_on_error=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: unknown option '$1'." >&2
      echo "" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$DIR" ]; then
        echo "Error: too many arguments." >&2
        exit 2
      fi
      DIR="$1"
      ;;
  esac
  shift
done

# Any remaining positional argument after '--'
if [ $# -gt 0 ]; then
  if [ -n "$DIR" ]; then
    echo "Error: too many arguments." >&2
    exit 2
  fi
  DIR="$1"
fi

DIR="${DIR:-.}"

DIR="$(cd "$DIR" 2>/dev/null && pwd)" || {
  echo "Error: directory not found or not accessible." >&2
  exit 1
}

echo "Running .sh files in: $DIR"

self="$(realpath "$0")"
fail_count=0
failed=""

# Write the sorted list to a temp file so the loop runs in the current shell
# (not a pipe subshell) and the failure tracking persists after the loop.
tmp_list="$(mktemp)"
find "$DIR" -maxdepth 1 -name "*.sh" | sort > "$tmp_list"

while IFS= read -r script; do
  [ -n "$script" ] || continue
  # Skip ourselves
  [ "$(realpath "$script")" = "$self" ] && continue
  echo "--- Running: $script"
  # Execute the script directly so its own shebang (bash, sh, ...) is honored.
  # Forcing "sh" here breaks scripts that rely on bash features (source, BASH_SOURCE, ...).
  if "$script"; then
    echo "------ Done: $script (exit code: 0)"
  else
    rc=$?
    echo "------ FAILED: $script (exit code: $rc)" >&2
    fail_count=$((fail_count + 1))
    failed="$failed  $script\n"
    if [ "$stop_on_error" -eq 1 ]; then
      rm -f "$tmp_list"
      echo "Stopping on first error (--stop-on-error)." >&2
      exit "$rc"
    fi
  fi
done < "$tmp_list"

rm -f "$tmp_list"

if [ "$fail_count" -gt 0 ]; then
  echo ""
  echo "Provisioning completed with $fail_count failed script(s):" >&2
  printf '%b' "$failed" >&2
  exit 1
fi

echo "Provisioning done."
