# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

set(top_repo_dir_path "${CMAKE_CURRENT_LIST_DIR}/../../..")
get_filename_component(top_repo_dir_path "${top_repo_dir_path}" ABSOLUTE)

macro(qt_ir_setup_test_include_paths)
    set(ir_script_path "${top_repo_dir_path}/cmake")
    list(APPEND CMAKE_MODULE_PATH
        "${ir_script_path}"
        "${ir_script_path}/3rdparty/cmake"
    )
    include(QtIRHelpers)
    qt_ir_include_all_helpers()
endmacro()
qt_ir_setup_test_include_paths()

# Used by add_RunCMake_test
set(CMAKE_CMAKE_COMMAND "${CMAKE_COMMAND}")
set(_isMultiConfig FALSE)
