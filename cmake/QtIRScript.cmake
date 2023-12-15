# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

# Sets up the include paths for all the helpers init-repository uses.
macro(qt_ir_setup_include_paths)
    list(APPEND CMAKE_MODULE_PATH
        "${CMAKE_CURRENT_LIST_DIR}"
        "${CMAKE_CURRENT_LIST_DIR}/3rdparty/cmake"
    )
    include(QtIRHelpers)
endmacro()

qt_ir_setup_include_paths()
qt_ir_include_all_helpers()
qt_ir_run_main_script()
