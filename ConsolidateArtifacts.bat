setlocal EnableDelayedExpansion

echo off

set destination=artifacts
set staticConfig=static
set dynamicConfig=dynamic
set platform=x64
set msvcVersion=msvc2015
set lib_path=Qt\%platform%-%msvcVersion%-%staticConfig%
set static_lib_path=%lib_path%\qtbase\bin\%platform%-%msvcVersion%-%staticConfig%

if exist "%destination%" rmdir "%destination%" /s/q

echo "Packaging library"
xcopy "%static_lib_path%\include"  "%destination%\include" /y/s/q/i
if !errorlevel! neq 0 exit /b !errorlevel!
xcopy "%static_lib_path%\lib"  "%destination%\lib" /y/s/q/i
if !errorlevel! neq 0 exit /b !errorlevel!
xcopy "%static_lib_path%\bin"  "%destination%\bin" /y/s/q/i
if !errorlevel! neq 0 exit /b !errorlevel!
xcopy "%static_lib_path%\plugins"  "%destination%\plugins" /y/s/q/i
if !errorlevel! neq 0 exit /b !errorlevel!

REM remove all intermediate files in the original library folder
rmdir "%lib_path%" /s /q
if !errorlevel! neq 0 exit /b !errorlevel!
pushd "%destination%"
rmdir "lib\cmake" /s /q
if !errorlevel! neq 0 exit /b !errorlevel!
del *.prl /s /q
if !errorlevel! neq 0 exit /b !errorlevel!
del *.pdb /s /q
if !errorlevel! neq 0 exit /b !errorlevel!

pushd bin
REM delete all applications except for necessary ones.
for %%i in (*.*) do if not "%%i"=="moc.exe" if not "%%i"=="rcc.exe" if not "%%i"=="uic.exe" del /q "%%i"
if !errorlevel! neq 0 exit /b !errorlevel!

exit /b 0