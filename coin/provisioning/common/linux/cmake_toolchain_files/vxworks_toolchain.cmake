# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

if(QT_VXWORKS_TOOLCHAIN_FILE)
    set(_original_toolchain_file "${QT_VXWORKS_TOOLCHAIN_FILE}")
elseif(DEFINED ENV{QT_VXWORKS_TOOLCHAIN_FILE})
    set(_original_toolchain_file "$ENV{QT_VXWORKS_TOOLCHAIN_FILE}")
else()
     message(FATAL_ERROR "QT_VXWORKS_TOOLCHAIN_FILE is not set.")
endif()

if(NOT EXISTS "${_original_toolchain_file}")
     message(FATAL_ERORR "${_original_toolchain_file} doesn't exists.")
endif()

include("${_original_toolchain_file}")
unset(_original_toolchain_file)

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES QT_VXWORKS_TOOLCHAIN_FILE)

set(_common_lib_path "${CMAKE_SYSROOT}/usr/lib/common")
set(EGL_INCLUDE_DIR ${CMAKE_SYSROOT}/usr/h/public CACHE PATH "Path to EGL include directory" FORCE)
set(EGL_LIBRARY ${_common_lib_path}/libgfxFslVivEGL.so CACHE PATH "Path to EGL lib" FORCE)
set(GLESv2_INCLUDE_DIR ${CMAKE_SYSROOT}/usr/h/public CACHE PATH "Path to GLES include directory" FORCE)
set(GLESv2_LIBRARY ${_common_lib_path}/libgfxFslVivGLESv2.so CACHE PATH "Path to GLES lib" FORCE)

set(VxWorksPlatformGraphics_DEFINES "-D_FSLVIV")
set(VxWorksPlatformGraphics_LIBRARIES_PACK
    "${_common_lib_path}/libgfxFslVivGAL.so"
    "${_common_lib_path}/libgfxFslVivGLSLC.so"
    "${_common_lib_path}/libgfxFslVivVDK.so"
    "${_common_lib_path}/libxml.so"
)

set(VxWorksPlatformGraphics_REQUIRED_LIBRARIES
    ${VxWorksPlatformGraphics_LIBRARIES_PACK}
    ${EGL_LIBRARY}
    ${GLESv2_LIBRARY}
)
unset(_common_lib_path)
