#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

# realpath is not included to macOS <= 12.
# dir=$(realpath "$1")
dir=$(cd "$1" && pwd)

dir_length=${#dir}
dylib_regex="^$dir/.*\.dylib$"

find "$dir" -type f -name '*.dylib' | while read -r library_path; do
    install_name=$(otool -D "$library_path" | sed -n '2p' | grep -E "$dylib_regex" )
    if [ -n "$install_name" ]; then
        fixed_install_name="@rpath${install_name:dir_length}"
        install_name_tool -id "$fixed_install_name" "$library_path"
    fi

    otool -L "$library_path" | awk '/\t/ {print $1}' | grep -E "$dylib_regex" | while read -r dependency_path; do
        fixed_dependency_path="@loader_path${dependency_path:dir_length}"
        install_name_tool -change "$dependency_path" "$fixed_dependency_path" "$library_path"
    done
done
