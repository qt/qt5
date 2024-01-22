#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Copies or lipos files from the given DESTDIR dirs to the respective install dir

set -e

for dir in "$@"; do
    echo "Processing files in $dir ..."
    pushd "$dir" >/dev/null
    find . -type f -or -type l | while read -r f; do
        dst="${f:1}"
        dstdir="$(dirname "$dst")"
        mkdir -p "$dstdir"

        if [[ -L "$f" ]]; then
            if [[ ! -L "$dst" && ! -d "$dst" && ! -f "$dst" ]]; then
                echo "Copying symlink $dir/$f to $dst"
                cp -P -n "$f" "$dst"
            fi
        elif [[ ! -f "$dst" ]]; then
            echo "Copying $dir/$f to $dst"
            cp -c "$f" "$dst"
        elif lipo -info "$f" >/dev/null 2>&1; then
            echo "Lipoing $dir/$f into $dst"
            lipo -create -output "$dst" "$dst" "$f"
        elif ! diff "$f" "$dst"; then
            echo "Error: File $f in $dir doesn't match destination $dst"
            exit 1
        fi
    done
    popd >/dev/null
done
