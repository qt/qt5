#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.

if [ -f /Users/qt/.zsh_history ]
then
  sudo chown qt:staff /Users/qt/.zsh_history
fi

if [ -f /Users/qt/.viminfo ]
then
  sudo chown qt:staff /Users/qt/.viminfo
fi
