:: Copyright (C) 2024 The Qt Company Ltd.
:: SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0

@echo off
setlocal ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
set script_dir_path=%~dp0
set script_dir_path=%script_dir_path:~0,-1%

set cmake_scripts_dir=%script_dir_path%\cmake
:: The '.' in 'echo.%*' ensures we don't print "echo is off" when no arguments are passed
:: https://devblogs.microsoft.com/oldnewthing/20170802-00/?p=96735
:: The space before the '>' makes sure that when we have a digit at the end of the args, we
:: don't accidentally concatenate it with the '>' resulting in '0>' or '2>' which redirects into the
:: file from a stream different than stdout, leading to broken or empty content.
echo.%* >init-repository.opt.in

call cmake -DIN_FILE=init-repository.opt.in -DOUT_FILE=init-repository.opt ^
    -P "%cmake_scripts_dir%\QtWriteArgsFile.cmake"
call cmake -DOPTFILE=init-repository.opt ^
    -P "%cmake_scripts_dir%\QtIRScript.cmake"

del init-repository.opt.in
del init-repository.opt
