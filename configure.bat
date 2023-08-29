@echo off
:: Copyright (C) 2020 The Qt Company Ltd.
:: SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0

set "srcpath=%~dp0"
set "configure=%srcpath%qtbase\configure.bat"
if not exist "%configure%" (
    echo %configure% not found. Did you forget to run "init-repository"? >&2
    exit /b 1
)

if not exist qtbase mkdir qtbase || exit /b 1

echo + cd qtbase
cd qtbase || exit /b 1

echo + %configure% -top-level %*
call %configure% -top-level %*
set err=%errorlevel%

cd ..

exit /b %err%
