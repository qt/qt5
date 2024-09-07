set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
endif()
if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_LIBRARY)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
endif()
if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_PACKAGE)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
endif()
if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_INCLUDE)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

set(CMAKE_FIND_ROOT_PATH $ENV{QNX_TARGET};$ENV{QNX_TARGET}/${CMAKE_SYSTEM_PROCESSOR})

set(_qnx_toolchain_arch gcc_ntox86_64)

set(CMAKE_C_COMPILER qcc)
set(CMAKE_C_COMPILER_TARGET ${_qnx_toolchain_arch})
set(CMAKE_CXX_COMPILER q++)
set(CMAKE_CXX_COMPILER_TARGET ${_qnx_toolchain_arch})

set(CMAKE_STRIP $ENV{QNX_HOST}/usr/bin/ntox86_64-strip)
set(CMAKE_AR $ENV{QNX_HOST}/usr/bin/ntox86_64-ar)

set(CMAKE_SYSROOT $ENV{QNX_TARGET})
