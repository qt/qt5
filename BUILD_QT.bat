setlocal EnableDelayedExpansion

rem The script assumed that perl, jom and python are already set in PATH. The output dir will be Qt\[BUILD_ID]
@SETLOCAL
@ECHO OFF
SET OUT_DIR=Qt
SET SRC_DIR=.
SET BUILD_ID=x64-msvc2015-static
SET QMAKESPEC=win32-msvc2015

call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x64
if !errorlevel! neq 0 exit /b !errorlevel!

SET PATH=%SRC_DIR%\qtbase\bin;%SRC_DIR%\gnuwin32\bin;%PATH%
SET PATH=%SRC_DIR%\qtrepotools\bin;%PATH%

@ECHO ON
call perl init-repository -f
if !errorlevel! neq 0 exit /b !errorlevel!
mkdir %OUT_DIR%\%BUILD_ID%
if !errorlevel! neq 0 exit /b !errorlevel!
pushd %OUT_DIR%\%BUILD_ID%
if !errorlevel! neq 0 exit /b !errorlevel!
call ..\..\configure -static -prefix %BUILD_ID% -platform %QMAKESPEC% -debug-and-release -confirm-license -opensource -opengl desktop -static -mp -qt-zlib -qt-pcre -qt-freetype -qt-libpng -qt-libjpeg -direct2d -qt-harfbuzz -skip qt3d -skip qtactiveqt -skip qtandroidextras -skip qtcanvas3d -skip qtconnectivity -skip qtdeclarative -skip qtdoc -skip qtenginio -skip qtgraphicaleffects -skip qtimageformats -skip qtlocation -skip qtmacextras -skip qtmultimedia -skip qtquickcontrols -skip qtscript -skip qtsensors -skip qtserialport -skip qtsvg -skip qttools -skip qttranslations -skip qtwayland -skip qtwebchannel -skip qtwebengine -skip qtwebsockets -skip qtx11extras -skip qtxmlpatterns -nomake examples -nomake tools -nomake tests
if !errorlevel! neq 0 exit /b !errorlevel!

CALL jom.exe /j 8 install
if !errorlevel! neq 0 exit /b !errorlevel!
@ECHO OFF

exit /b 0
