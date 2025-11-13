# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

list(APPEND CMAKE_MODULE_PATH "${EXTRA_MODULE_PATH}")
include(Common)

# The file is included separately from Common.cmake because it has side-effects
# that we want to apply only in the RunCMake part of the test.
include(RunCMake)

# Uses prefix set from outside scope.
function(run_suite_command name)
    set(RunCMake_TEST_COMMAND "${ARGN}")
    set(RunCMake-check-file "check.cmake")

    set(args ${ARGN})
    list(JOIN args " " args_str)
    set(working_dir "${RunCMake_TEST_COMMAND_WORKING_DIRECTORY}")
    message(STATUS "Running command: '${args_str}' in dir: '${working_dir}'")

    run_cmake("${prefix}${name}")
    # set by the check file above.
    if(should_error_out)
        message(FATAL_ERROR "Command ${prefix}${name} failed. Exiting early.")
    endif()
endfunction()

macro(read_expected_output test file_name)
    set(expect "")
    set(expect_path "${RunCMake_SOURCE_DIR}/${file_name}-stdout.txt")
    if(EXISTS "${expect_path}")
        file(READ "${expect_path}" expect)
    endif()

    if(NOT expect)
        message(FATAL_ERROR "No expected output for test ${file_name}. "
                "Make sure to add a ${file_name}-stdout.txt file.")
    endif()

    set(RunCMake_TEST_EXPECT_stdout "${expect}")
endmacro()

function(run_suite_test test_name)
    set(options "ONLY_CMAKE")
    set(oneValueArgs "EXPECT_NAME")
    set(multiValueArgs "COMMAND_ARGS")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(prefix STREQUAL "perl" AND arg_ONLY_CMAKE)
        return()
    endif()

    if(arg_EXPECT_NAME)
        set(expect_name "${arg_EXPECT_NAME}")
    else()
        set(expect_name "${test_name}")
    endif()

    read_expected_output(${test_name} ${expect_name})
    run_suite_command(${test_name} ${arg_COMMAND_ARGS})
endfunction()

function(run_suite)
    set(options
        USE_PERL_SCRIPT
    )
    set(oneValueArgs "")
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(arg_USE_PERL_SCRIPT)
        set(use_perl_script TRUE)
        set(prefix "perl")
        set(extra_ir_args "")
    else()
        set(use_perl_script FALSE)
        set(prefix "cmake")
        # When testing the cmake script, we don't want to resolve deps by default and
        # we want output to be the same as the one shown by the perl script.
        set(extra_ir_args "--no-resolve-deps" "--perl-identical-output")
    endif()

    # Set in Common.cmake
    set(local_clone_url "${top_repo_dir_path}")

    # Path to temp qt6 dir based on script used.
    set(tmp_path "${CMAKE_CURRENT_SOURCE_DIR}/tmp_${prefix}")
    set(qt6_repo_dir "${tmp_path}/qt6")

    # Path to init-repository script
    set(init_repository_script_path "${qt6_repo_dir}/init-repository")
    if(use_perl_script)
        string(APPEND init_repository_script_path ".pl")

        # Need to call perl explicitly, especially on Windows
        list(PREPEND init_repository_script_path perl)
    elseif(CMAKE_HOST_WIN32)
        string(APPEND init_repository_script_path ".bat")
    endif()

    # Clean up the temp qt6 repo dir.
    file(REMOVE_RECURSE "${qt6_repo_dir}")
    file(REMOVE_RECURSE "${tmp_path}")
    file(MAKE_DIRECTORY "${tmp_path}")
    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${tmp_path}")

    set(code_qt_io_mirror "https://code.qt.io/qt/qt5.git")
    set(gerrit_mirror "https://codereview.qt-project.org/qt/qt5")

    set(coin_git_ip_port "$ENV{QT_COIN_GIT_DAEMON}")
    set(ci_mirror "git://${coin_git_ip_port}/qt-project")
    set(ci_clone_url "${ci_mirror}/qt/qt5.git")

    if(coin_git_ip_port)
        set(remote_clone_url "${ci_clone_url}")
    else()
        set(remote_clone_url "${code_qt_io_mirror}")
    endif()

    # Make a copy of the qt6 repo on which the test will operate on.
    # On the CI we clone qt6 from one of the following sources, in order:
    # - the Coin CI git mirror
    # - or from code.qt.io
    # We do a clone, because 'local_clone_url' is usually not a git repo in the CI,
    # but only a source archive.
    # On a local build where a ci_ref is not specified, we use the current qt6 checkout
    # from 'local_clone_url'.
    set(ci_ref "$ENV{TESTED_MODULE_REVISION_COIN}")
    if(ci_ref)
        set(final_clone_url "${remote_clone_url}")
    else()
        set(final_clone_url "${local_clone_url}")
    endif()

    run_suite_command(0010_prepare_qt6_clone git clone "${final_clone_url}" qt6 --quiet)
    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${qt6_repo_dir}")

    # On the CI we also checkout the exact tested ref, so it behaves as it would with locally.
    if(ci_ref)
        run_suite_command(0011_fetch_ci_qt6_ref git fetch "${gerrit_mirror}" "${ci_ref}" --quiet)
        run_suite_command(0012_checkout_ci_qt6_ref git checkout FETCH_HEAD --quiet)
    endif()

    # Adjust its remote url to be the chosen mirror rather the local url.
    run_suite_command(0020_set_qt6_remote_url git remote set-url origin "${remote_clone_url}")

    # Ignore certain lines
    set(RunCMake_TEST_EXTRA_IGNORE_LINE_REGEX
        "|Trace will be written to"
        "|Put cmake in trace mode, but with variables expanded"
        "|Put cmake in trace mode and redirect trace output"
    )

    # Merge stdout with stderr, otherwise we can't test for the same output across script
    # implementations, because CMake has no easy way to control with output stream
    # should be used.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    # Initialize just qtsvg
    run_suite_test(0030_ir_qtsvg
        COMMAND_ARGS ${init_repository_script_path} --module-subset=qtsvg ${extra_ir_args})

    # Asking to do it again will refuse to do it, unless forced, because the repo has already been
    # initialized. Only do this check for cmake, because the perl script checks for initialization
    # if qtbase is initialized, and we don't want to test that because cloning qtbase just for the
    # test is too slow.
    run_suite_test(0040_ir_qtsvg_again
        ONLY_CMAKE
        COMMAND_ARGS ${init_repository_script_path} --module-subset=qtsvg ${extra_ir_args})

    # Configuring without a module-subset will initialize qtsvg again, because the new behavior
    # of the cmake script is to initialize previously existing submodules, rather than all of them.
    run_suite_test(0050_ir_existing
        ONLY_CMAKE
        COMMAND_ARGS ${init_repository_script_path} -f ${extra_ir_args})

    # Initialize more than one submodule, choosing the smaller ones, for faster cloning.
    run_suite_test(0060_ir_shadertools_and_svg
        COMMAND_ARGS ${init_repository_script_path}
            --module-subset=qtshadertools,qtsvg -f
            ${extra_ir_args})

    # Initialize qttools with dependencies, but without qtbase and qtdeclarative.
    # This should also clone qtactiveqt.
    list(REMOVE_ITEM extra_ir_args "--no-resolve-deps")
    run_suite_test(0070_ir_qttools_with_deps
        ONLY_CMAKE
        COMMAND_ARGS ${init_repository_script_path}
            --module-subset=qttools,-qtbase,-qtdeclarative,-qtimageformats,-qtlanguageserver -f
            ${extra_ir_args})

    # Unset the working dir for further tests.
    unset(RunCMake_TEST_COMMAND_WORKING_DIRECTORY)
endfunction()

run_suite()
run_suite(USE_PERL_SCRIPT)
