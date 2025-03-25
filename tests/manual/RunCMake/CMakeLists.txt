# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(tst_run_cmake_tests)
enable_testing()

include("${CMAKE_CURRENT_SOURCE_DIR}/Common.cmake")

add_RunCMake_test(InitRepository
    -DEXTRA_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
)
add_RunCMake_test(ConfigureBuildQt
    -DEXTRA_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
)
