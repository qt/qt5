# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# The script produces the list of qt submodules that are required to build the submodules listed
# in the QT_BUILD_SUBMODULES variable. The resulting list preserves the required build order.
# Usage:
# cmake [-DQT_BUILD_SUBMODULES="<repo;..>"] [-BUILD_<repo>=<TRUE|FALSE>] \
#     [-DSEPARATOR=<list separator>] \
#    -P <path/to>/qt6/cmake/QtSortModuleDependencies.cmake
cmake_minimum_required(VERSION 3.16)

include(${CMAKE_CURRENT_LIST_DIR}/QtTopLevelHelpers.cmake)

qt_internal_collect_modules_only(result "${QT_BUILD_SUBMODULES}")

if(NOT DEFINED SEPARATOR)
    set(SEPARATOR " ")
endif()

list(JOIN result "${SEPARATOR}" result)
message("${result}")
