# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_MODULE_PATH "${EXTRA_MODULE_PATH}")
include(Common)

# The file is included separately from Common.cmake because it has side-effects
# that we want to apply only in the RunCMake part of the test.
include(RunCMake)

# Include the test specific utilities.
include(Utils)

macro(test_per_repo_prefix_qt)
    add_test_case(
        TEST_NAME "per_repo_prefix"
        TEST_GROUPS per_repo prefix
        TEST_ARGS
            BUILD_STANDALONE_TESTS
            BUILD_STANDALONE_EXAMPLES_IN_TREE
            BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS
            RECONFIGURE_WITHOUT_ARGS_IMMEDIATELY
            RECONFIGURE_STANDALONE_PARTS
    )
endmacro()

macro(test_per_repo_no_prefix_qt)
    add_test_case(
        TEST_NAME "per_repo_no_prefix"
        TEST_GROUPS per_repo no_prefix
        TEST_ARGS
            NO_PREFIX
            BUILD_STANDALONE_TESTS
            BUILD_STANDALONE_EXAMPLES_IN_TREE
            BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS
            RECONFIGURE_WITHOUT_ARGS_AFTER_BUILD
            BUILD_AFTER_RECONFIGURE
            RECONFIGURE_STANDALONE_PARTS
    )
endmacro()

macro(test_per_repo_prefix_in_tree_tests_and_examples_qt)
    add_test_case(
        TEST_NAME "per_repo_prefix_in_tree_tests_and_examples"
        TEST_GROUPS per_repo prefix in_tree_tests_and_examples
        TEST_ARGS
            BUILD_IN_TREE_TESTS
            BUILD_IN_TREE_EXAMPLES
    )
endmacro()

macro(test_per_repo_no_prefix_in_tree_tests_and_examples_qt)
    add_test_case(
        TEST_NAME "per_repo_no_prefix_in_tree_tests_and_examples"
        TEST_GROUPS per_repo no_prefix in_tree_tests_and_examples
        TEST_ARGS
            NO_PREFIX
            BUILD_IN_TREE_TESTS
            BUILD_IN_TREE_EXAMPLES
    )
endmacro()

macro(test_per_repo_no_prefix_in_source)
    add_test_case(
        TEST_NAME "per_repo_no_prefix_in_source"
        TEST_GROUPS per_repo no_prefix in_source
        TEST_ARGS
            NO_PREFIX
            IN_SOURCE
    )
endmacro()

macro(test_top_level_prefix_qt)
    add_test_case(
        TEST_NAME "top_level_prefix"
        TEST_GROUPS top_level prefix
        TEST_ARGS
            TOP_LEVEL
            BUILD_STANDALONE_TESTS
            BUILD_STANDALONE_EXAMPLES_IN_TREE
            BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS
    )
endmacro()

macro(test_top_level_no_prefix_qt)
    add_test_case(
        TEST_NAME "top_level_no_prefix"
        TEST_GROUPS top_level no_prefix
        TEST_ARGS
            TOP_LEVEL
            NO_PREFIX
            BUILD_STANDALONE_TESTS
            BUILD_STANDALONE_EXAMPLES_IN_TREE
            BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS
    )
endmacro()

macro(test_top_level_no_prefix_in_source)
    add_test_case(
        TEST_NAME "top_level_no_prefix_in_source"
        TEST_GROUPS top_level no_prefix in_source
        TEST_ARGS
            TOP_LEVEL
            NO_PREFIX
            IN_SOURCE
    )
endmacro()

macro(test_top_level_prefix_in_tree_tests_and_examples_qt)
    add_test_case(
        TEST_NAME "top_level_prefix_in_tree_tests_and_examples"
        TEST_GROUPS top_level prefix in_tree_tests_and_examples
        TEST_ARGS
            TOP_LEVEL
            BUILD_IN_TREE_TESTS
            BUILD_IN_TREE_EXAMPLES
    )
endmacro()

macro(test_top_level_no_prefix_in_tree_tests_and_examples_qt)
    add_test_case(
        TEST_NAME "top_level_no_prefix_in_tree_tests_and_examples"
        TEST_GROUPS top_level no_prefix in_tree_tests_and_examples
        TEST_ARGS
            TOP_LEVEL
            NO_PREFIX
            BUILD_IN_TREE_TESTS
            BUILD_IN_TREE_EXAMPLES
    )
endmacro()

# Collect all test cases and groups.
macro(collect_tests)
    set(TEST_CASES "")
    set(TEST_GROUPS "")

    test_per_repo_no_prefix_qt()
    test_top_level_no_prefix_qt()

    # This usually tested in regular CI as well.
    test_per_repo_prefix_qt()

    test_top_level_prefix_qt()

    # TODO: These don't work atm due to some failed include(Targets) files.
    #test_per_repo_no_prefix_in_tree_tests_and_examples_qt()
    #test_top_level_no_prefix_in_tree_tests_and_examples_qt()
    #test_per_repo_prefix_in_tree_tests_and_examples_qt()
    #test_top_level_prefix_in_tree_tests_and_examples_qt()

    test_per_repo_no_prefix_in_source()
    test_top_level_no_prefix_in_source()

    # TODO: Cross-builds.
    # TODO: qt5.git builds with all submodules. Current limitation is that the sync-to
    # script can't handle multiple modules at once, nor an "all repos" case.
    # so we might have to call init-repository in that case.
    # TODO: Unix Makefile builds.
    # TODO: Build examples and tests, not only configure them.
    # TODO: Perhaps run some of the cmake auto tests in configs that are not tested in CI
    # like no-prefix builds.

    message(STATUS "Available test cases: ${TEST_CASES}")
    message(STATUS "Available test groups: ${TEST_GROUPS}")
    foreach(group IN LISTS TEST_GROUPS)
        message(STATUS "Available test cases for group ${group}: ${TEST_GROUPS_${group}}")
    endforeach()
endmacro()

run_tests()
