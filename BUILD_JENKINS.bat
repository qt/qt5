setlocal EnableDelayedExpansion

call BUILD_QT.bat
if %errorlevel% neq 0 exit /b %errorlevel%

call BUILD_QT_DLL.bat
if %errorlevel% neq 0 exit /b %errorlevel%

call ConsolidateArtifacts.bat
if %errorlevel% neq 0 exit /b %errorlevel%
