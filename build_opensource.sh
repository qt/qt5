#!bash

SCRIPT=$(dirname "$0")
cd $SCRIPT
BASEDIR=`pwd`
ENABLE_QT_DEBUG_VER_BUILD=0
echo $BASEDIR
prj_path="build_opensource"
if [ "$1" != "" ]; then
    prj_path="$1"
fi
echo $prj_path

mkdir -p $prj_path && cd $prj_path

build_fun()
{
    BUILD_DIRNAME="build_$1"
    QT_INSTALL_DIR="$BASEDIR/$prj_path/Qt5.12.3_$1"

    if [ $ENABLE_QT_DEBUG_VER_BUILD == 1 ]; then
        BUILD_DIRNAME="build_$1_debug"
        QT_INSTALL_DIR="$BASEDIR/$prj_path/Qt5.12.3_$1_debug"
    fi


    mkdir -p $BUILD_DIRNAME && cd $BUILD_DIRNAME
    if [ ! -f Makefile ];then
        $BASEDIR/configure -prefix $QT_INSTALL_DIR -skip qt3d -skip qtwebengine -skip qtlocation -skip qtconnectivity -nomake examples -nomake tests -device-option QMAKE_APPLE_DEVICE_ARCHS="$1" QMAKE_MACOSX_DEPLOYMENT_TARGET=10.13 -opensource -confirm-license

        if [ $ENABLE_QT_DEBUG_VER_BUILD == 1 ]; then
            $BASEDIR/configure -prefix $QT_INSTALL_DIR -debug -skip qt3d -skip qtwebengine -skip qtlocation -skip qtconnectivity -nomake examples -nomake tests -device-option QMAKE_APPLE_DEVICE_ARCHS="$1" QMAKE_MACOSX_DEPLOYMENT_TARGET=10.13 -opensource -confirm-license
        fi
    
        sed -i "" '/QMAKE *=/ s/$/ QMAKE_APPLE_DEVICE_ARCHS="'$1'"/' Makefile
        cd qtbase/qmake/
        make clean
        sed -i "" '/CXX =/ s/$/  -arch '$1'/' Makefile
        make
        cd -
    fi
    set -e
    make -j8 > /dev/null
    set +e
    make -j8 install > /dev/null
    
    cd ..
}

echo build x86_64 debug_ver=$ENABLE_QT_DEBUG_VER_BUILD
build_fun "x86_64"
echo build arm64 debug_ver=$ENABLE_QT_DEBUG_VER_BUILD
build_fun "arm64"
echo make universal
cd $BASEDIR
python3 make_universal.py $prj_path/Qt5.12.3 $prj_path/Qt5.12.3_x86_64 $prj_path/Qt5.12.3_arm64
# arm64 版本的 macdeployqt 无法正确运行，于是使用 x86_64 的版本
cp $prj_path/Qt5.12.3_x86_64/bin/macdeployqt $prj_path/Qt5.12.3/bin
# qt.conf 用来指定当前 qmake 所依赖的的 Qt 库
cp qt.conf $prj_path/Qt5.12.3/bin
