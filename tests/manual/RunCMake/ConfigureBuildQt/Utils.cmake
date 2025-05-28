# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# Wrapper for RunCMake's run_cmake, with extra logging and early failure handling.
function(run_command prefix name)
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

# Query the var name from the CMake cache or the environment or use a default value.
function(get_cmake_or_env_or_default out_var var_name_to_check default_value)
    # Load the cache variables from the build dir containing the ConfigueBuildQt test
    # RunCMake_BINARY_DIR is not actually created at this point so we have to normalize the path
    cmake_path(SET actual_BINARY_DIR NORMALIZE "${RunCMake_BINARY_DIR}/..")
    load_cache("${actual_BINARY_DIR}"
        READ_WITH_PREFIX CACHE_VAL_ "${var_name_to_check}"
    )
    if(${var_name_to_check})
        # This is set within the script, highest priority
        set(value "${var_name_to_check}")
    elseif(DEFINED ENV{${var_name_to_check}})
        # This may be used to change parameters at ctest runtime
        set(value "$ENV{${var_name_to_check}}")
    elseif(DEFINED CACHE_VAL_${var_name_to_check})
        # These parameters are set at configure time
        set(value "${CACHE_VAL_${var_name_to_check}}")
    else()
        set(value "${default_value}")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Sets verbose command output based on a cmake var or env var for run_command calls.
macro(setup_verbose_command_output)
    get_cmake_or_env_or_default(verbose_command_output QT_CI_BUILD_QT_VERBOSE_COMMAND_OUTPUT "ON")
    if(verbose_command_output)
        # Show output as it arrives.
        # This uses a custom qtbase patch of RunCMake.
        set(RunCMake_TEST_ECHO_OUTPUT_VARIABLE TRUE)
        set(RunCMake_TEST_ECHO_ERROR_VARIABLE TRUE)
    endif()
endmacro()

# Gets the remote git base URL for qt repositories.
function(get_repo_base_url out_var)
    # This Coin CI git daemon IP is set in all CI jobs.
    # Prefer using it when available, to avoid general network issues.
    # Sample value: QT_COIN_GIT_DAEMON=10.215.0.212:9418
    get_cmake_or_env_or_default(coin_git_ip_port QT_COIN_GIT_DAEMON "")

    # Allow opting out of using the coin git daemon.
    get_cmake_or_env_or_default(skip_coin_git QT_CI_BUILD_QT_SKIP_COIN_GIT_DAEMON FALSE)

    # Allow override of the default remote.
    get_cmake_or_env_or_default(git_remote QT_CI_BUILD_QT_GIT_REMOTE "")

    if(coin_git_ip_port AND NOT skip_coin_git)
        set(value "git://${coin_git_ip_port}/qt-project")
    elseif(git_remote)
        set(value "${git_remote}")
    else()
        set(value "https://code.qt.io")
    endif()

    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

function(get_default_repo_to_sync out_var)
    set(${out_var} "qtdeclarative" PARENT_SCOPE)
endfunction()

function(get_default_ref_to_sync out_var)
    set(${out_var} "dev" PARENT_SCOPE)
endfunction()

# Decides module to clone to sync to and the ref to sync to.
function(setup_qt_repos_to_clone)
    # Allow pinning the sha1 or any other git ref, based on a cmake var or env var.
    get_default_repo_to_sync(default_module)
    get_default_ref_to_sync(default_ref)
    get_cmake_or_env_or_default(SYNC_MODULE QT_CI_BUILD_QT_SYNC_MODULE "${default_module}")
    get_cmake_or_env_or_default(SYNC_TO_REF QT_CI_BUILD_QT_PIN_GIT_REF "${default_ref}")

    message(STATUS "Will sync to module '${SYNC_MODULE}' at ref '${SYNC_TO_REF}'")

    set(SYNC_TO_REF "${SYNC_TO_REF}" PARENT_SCOPE)
    set(SYNC_MODULE "${SYNC_MODULE}" PARENT_SCOPE)
endfunction()

# A parser extra cherry-pick or checkout refs to apply to the initialized submodules.
# value - the string to parse.
# out_prefix - the prefix to use for the output variables.
# Sets the following variables:
# <out_prefix>_repos - a list of the repos to apply the changes to.
# <out_prefix>_<repo_name> - the list of refs to apply to the given repo.
function(parse_cherry_pick_entries out_prefix value)
    if(value STREQUAL "")
        set(${out_prefix}_repos "" PARENT_SCOPE)
        return()
    endif()

    set(result "")
    set(repos "")

    # Format is as follows.
    # "repo sha1,sha2,sha3|repo2 sha1,sha2,sha3"
    # E.g.
    # set(cherrypicks "qtbase a,b,c|qtdeclarative d,e,f")
    string(REPLACE "|" ";" repo_tuples "${value}")
    foreach(repo_tuple IN LISTS repo_tuples)
        set(result "")
        string(REPLACE " " ";" repo_tuple "${repo_tuple}")
        list(LENGTH repo_tuple tuple_len)
        if(NOT tuple_len EQUAL 2)
            message(FATAL_ERROR "Invalid cherry-pick entry: ${repo_tuple}")
        endif()
        list(GET repo_tuple 0 repo_name)
        list(GET repo_tuple 1 refs)
        string(REPLACE "," ";" refs "${refs}")
        list(APPEND repos "${repo_name}")
        foreach(ref IN LISTS refs)
            list(APPEND result "${ref}")
        endforeach()

        set(${out_prefix}_${repo_name} "${result}" PARENT_SCOPE)
    endforeach()
    set(${out_prefix}_repos "${repos}" PARENT_SCOPE)
endfunction()

# Applies extra gerrit cherry-picks or checks out repos to given ref for the initialized repos.
# This allows applying patches before they are merged in gerrit.
# These can be set for example in a Coin integration or when configuring the test locally.
# The changes are applied in the order they are given, with cherry-picks coming after the check
# outs.
# The format for the values is as follows:
#   QT_CI_BUILD_QT_EXTRA_CHERRYPICK_CHANGES='qtbase ref1,ref2|qtdeclarative ref3,ref4'
# Example usage on the command line:
#  export QT_CI_BUILD_QT_EXTRA_CHERRYPICK_CHANGES='qtbase 6d2b6b810163610a5b56cef19b196286708acabb'
#  export QT_CI_BUILD_QT_EXTRA_CHECKOUT_CHANGES='qtsvg refs/changes/10/624710/5'
#  ctest -V -R RunCMake.ConfigureBuildQt
function(apply_extra_gerrit_changes)
    get_cmake_or_env_or_default(cherrypicks QT_CI_BUILD_QT_EXTRA_CHERRYPICK_CHANGES "")
    get_cmake_or_env_or_default(checkouts QT_CI_BUILD_QT_EXTRA_CHECKOUT_CHANGES "")

    set(src_dir_backup "${RunCMake_TEST_COMMAND_WORKING_DIRECTORY}")

    parse_cherry_pick_entries(check_outs "${checkouts}")
    if(check_outs_repos)
        message(STATUS "Applying extra checkout changes for: ${check_outs_repos}")
    endif()
    foreach(repo_name IN LISTS check_outs_repos)
        set(refs "${check_outs_${repo_name}}")
        list(LENGTH refs refs_len)
        if(refs_len GREATER 1)
            message(FATAL_ERROR "More than one checkout ref specified for: ${repo_name}")
        endif()
        foreach(ref IN LISTS refs)
            set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${src_dir_backup}/${repo_name}")
            run_command("extra_" git_fetch_checkout_sha1
                git fetch "https://codereview.qt-project.org/qt/${repo_name}" "${ref}"
            )
            run_command("extra_" git_checkout_fetch_head
                git checkout FETCH_HEAD
            )
        endforeach()
    endforeach()

    parse_cherry_pick_entries(cherry_picks "${cherrypicks}")
    if(cherry_picks_repos)
        message(STATUS "Applying extra cherry-pick changes for: ${cherry_picks_repos}")
    endif()
    foreach(repo_name IN LISTS cherry_picks_repos)
        set(refs "${cherry_picks_${repo_name}}")
        foreach(ref IN LISTS refs)
            set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${src_dir_backup}/${repo_name}")
            run_command("extra_" git_fetch_cherry_pick_sha1
                git fetch "https://codereview.qt-project.org/qt/${repo_name}" "${ref}"
            )
            run_command("extra_" git_cherry_pick_fetch_head
                git cherry-pick FETCH_HEAD
            )
        endforeach()
    endforeach()
endfunction()

# Maeks a copy of the current qt5.git repo of into a temporary directory, and syncs it to the
# given module and ref, initializing any missing submodules along the way,
# as well as applies any extra gerrit changes.
# Also sets the root build dir path for all future Qt builds.
#
# In the CI this instead does a clean clone from the official mirror, instead of a copy, due to
# missing .git info.
#
# Does not rerun the cloning and syncing if the sources are already synced, based on the presence
# of the sources_synced.txt file.
function(setup_qt_sources)
    set(opt_args "")
    set(single_args "")
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    # Set in Common.cmake
    set(local_clone_url "${top_repo_dir_path}")

    # Path to working dir based on test build path.
    set(working_dir "${RunCMake_BINARY_DIR}")
    set(top_level_src_dir "${working_dir}/src")
    set(builds_path "${working_dir}/builds")

    # Avoid creating many empty build dirs for each run_cmake command, by always reusing the
    # same one.
    set(RunCMake_TEST_NO_CLEAN TRUE)
    set(RunCMake_TEST_NO_CLEAN TRUE PARENT_SCOPE)
    set(RunCMake_TEST_BINARY_DIR "${working_dir}")
    set(RunCMake_TEST_BINARY_DIR "${working_dir}" PARENT_SCOPE)

    # This used by some of the other functions.
    set(TOP_LEVEL_SRC_DIR "${top_level_src_dir}" PARENT_SCOPE)
    set(BUILDS_PATH "${builds_path}" PARENT_SCOPE)

    if(EXISTS "${working_dir}/sources_synced.txt")
        # Return early for now, not to retouch the sources, and thus
        # cause rebuilds when re-running the test.
        message(STATUS "Skipping setting up sources as they are already synced. "
            "Remove ${working_dir}/sources_synced.txt to re-sync.")
        return()
    endif()

    # Prepare paths.
    file(MAKE_DIRECTORY "${working_dir}")
    file(MAKE_DIRECTORY "${builds_path}")

    # prefix is empty for now.
    set(prefix "")

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${working_dir}")

    set(code_qt_io_mirror "https://code.qt.io/qt/qt5.git")
    set(gerrit_mirror "https://codereview.qt-project.org/qt/qt5")

    # Make a copy of the qt6 repo on which the test will operate on.
    # On the CI we clone it from the official mirror, because we don't have a git repo, but only
    # a source archive.
    # On a local build we use the current qt6 checkout.
    set(ci_ref "$ENV{TESTED_MODULE_REVISION_COIN}")
    if(ci_ref)
        set(final_clone_url "${code_qt_io_mirror}")
    else()
        set(final_clone_url "${local_clone_url}")
    endif()

    setup_verbose_command_output()

    # Make a copy of the qt6 repo to operate on it.
    if(NOT EXISTS "${top_level_src_dir}")
        message(STATUS "Cloning qt6 repo to: ${top_level_src_dir} from ${final_clone_url}")
        run_command("${prefix}" prepare_qt6_clone git clone "${final_clone_url}"
            "${top_level_src_dir}" --quiet)
    else()
        message(STATUS "Skipping cloning qt6 repo as it already exists at: ${top_level_src_dir}")
    endif()

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${top_level_src_dir}")

    # On the CI we also checkout the exact tested ref, so it behaves as it would with locally.
    if(ci_ref)
        run_command("${prefix}" fetch_ci_qt6_ref git fetch "${gerrit_mirror}" "${ci_ref}" --quiet)
        run_command("${prefix}" checkout_ci_qt6_ref git checkout FETCH_HEAD --quiet)
    endif()

    # Merge stdout with stderr, to avoid having stderr output from git trigger errors.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    get_cmake_or_env_or_default(use_local USE_LOCAL_SUBMODULE_SYMLINKS OFF)
    if(use_local)
        file(GLOB qt_submodules RELATIVE "${top_level_src_dir}" "${top_level_src_dir}/qt*")
        foreach(submodule IN LISTS qt_submodules)
            message(STATUS
                "Making a symlink of submodule ${submodule} "
                "pointing to ${top_level_src_dir}/${submodule}"
            )
            file(REMOVE_RECURSE "${top_level_src_dir}/${submodule}")
            file(CREATE_LINK "${top_repo_dir_path}/${submodule}" "${top_level_src_dir}/${submodule}"
            SYMBOLIC)
        endforeach()
    else()
        # Adjust its remote url not to be the local url.
        get_repo_base_url(repo_base_url)
        set(remote_clone_url "${repo_base_url}/qt/qt5.git")
        run_command("${prefix}" set_remote_url git remote set-url origin "${remote_clone_url}")

        # Sync to given module.
        run_command("${prefix}" git_sync_to_${SYNC_MODULE}
                ${CMAKE_COMMAND}
                "-DSYNC_TO_MODULE=${SYNC_MODULE}"
                "-DSYNC_TO_BRANCH=${SYNC_TO_REF}"
                -DSHOW_PROGRESS=1
                -DVERBOSE=1
                -DGIT_DEPTH=1
                -P cmake/QtSynchronizeRepo.cmake
        )

        apply_extra_gerrit_changes()
    endif()

    file(TOUCH "${working_dir}/sources_synced.txt")
endfunction()

# Compute the list of submodules that will be built and skipped based on the module to sync to.
function(setup_list_of_repos_to_build)
    # Fake set the CMAKE_CURRENT_SOURCE_DIR so that we can parse the dependencies.
    set(CMAKE_CURRENT_SOURCE_DIR "${TOP_LEVEL_SRC_DIR}")

    set(sort_module_args "")
    set(optional_submodules_skipped "")
    get_cmake_or_env_or_default(exclude_optional_deps EXCLUDE_OPTIONAL_DEPS "ON")
    if(exclude_optional_deps)
        list(APPEND sort_module_args
            EXCLUDE_OPTIONAL_DEPS
            EXCLUDE_OPTIONAL_DEPS_VAR optional_submodules_skipped
        )
    endif()

    # TODO: hard-coding how to deal with qtdeclarative here for now
    # We need qtshadertools to build standalone tests in qtdeclarative because of qtquick
    if("qtdeclarative" IN_LIST SYNC_MODULE)
        list(PREPEND SYNC_MODULE qtshadertools)
    endif()

    qt_internal_sort_module_dependencies("${SYNC_MODULE}" initial_submodules ${sort_module_args})
    set(final_submodules ${initial_submodules})

    get_default_repo_to_sync(default_module)

    # Skip any submodules that were explicitly set.
    get_cmake_or_env_or_default(skip_submodules QT_CI_BUILD_QT_SKIP_SUBMODULES "")
    if(skip_submodules)
        # Support semicolons and commas.
        string(REPLACE "," ";" skip_submodules "${skip_submodules}")
    endif()
    list(APPEND skip_submodules ${optional_submodules_skipped})
    list(REMOVE_DUPLICATES skip_submodules)

    if(skip_submodules)
        list(REMOVE_ITEM final_submodules ${skip_submodules})
    endif()

    message(STATUS "Initial submodules: ${initial_submodules}")
    if(skip_submodules)
        message(STATUS "Skipping submodules: ${skip_submodules}")
    endif()
    message(STATUS "Final submodules: ${final_submodules}")

    # Will be used by other functions to decide which repos to build.
    set(QT_BUILD_SUBMODULES "${final_submodules}" PARENT_SCOPE)
    set(QT_SKIP_SUBMODULES "${skip_submodules}" PARENT_SCOPE)
endfunction()

# Copies the top-level qt sources to the given destination, to facilitate clean in-source builds.
function(copy_qt_sources)
    set(opt_args "")
    set(single_args
        DESTINATION_PATH
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    if(NOT arg_DESTINATION_PATH)
        message(FATAL_ERROR "DESTINATION_PATH is required.")
    endif()

    if(EXISTS "${arg_DESTINATION_PATH}/CMakeLists.txt")
        message(STATUS "Skipping copying sources to ${arg_DESTINATION_PATH} as it already has "
            "contents. Remove the root CMakeLists.txt file to re-copy.")
        return()
    endif()

    message(STATUS "Copying sources to ${arg_DESTINATION_PATH}")
    file(GLOB files_top_level "${TOP_LEVEL_SRC_DIR}/*")
    foreach(top_path IN LISTS files_top_level)
        # Skip copying qt5 .git dir.
        if(top_path STREQUAL "${TOP_LEVEL_SRC_DIR}/.git")
            continue()
        endif()

        if(IS_DIRECTORY "${top_path}")
            get_filename_component(top_dir_name "${top_path}" NAME)
            set(child_destination_path "${arg_DESTINATION_PATH}/${top_dir_name}")
            file(MAKE_DIRECTORY "${child_destination_path}")
            file(GLOB child_paths "${top_path}/*")
            foreach(child_path IN LISTS child_paths)
                # Skip copying repo .git dir.
                if(child_path STREQUAL "${top_path}/.git")
                    continue()
                endif()

                file(COPY "${child_path}" DESTINATION "${child_destination_path}")
            endforeach()
        else()
            file(COPY "${top_path}" DESTINATION "${arg_DESTINATION_PATH}")
        endif()
    endforeach()
endfunction()

# Common helper used in a few functions.
macro(check_and_set_common_qt_configure_options)
    if(NOT arg_TEST_NAME)
        message(FATAL_ERROR "TEST_NAME is required.")
    endif()
    set(test_name "${arg_TEST_NAME}")

    if(NOT arg_REPO_NAME)
        message(FATAL_ERROR "REPO_NAME is required.")
    endif()

    set(repo_name "${arg_REPO_NAME}")

    if(NOT arg_BUILD_DIR_ROOT_PATH)
        message(FATAL_ERROR "BUILD_DIR_ROOT_PATH is required.")
    endif()

    set(build_dir_root "${arg_BUILD_DIR_ROOT_PATH}")

    if(NOT arg_REPO_PATH)
        message(FATAL_ERROR "REPO_PATH is required.")
    endif()
    set(repo_path "${arg_REPO_PATH}")
endmacro()

function(get_libexec_dir out_var)
    if(CMAKE_HOST_WIN32)
        set(value "bin")
    else()
        set(value "libexec")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

function(get_executable_suffix)
    if(CMAKE_HOST_WIN32)
        set(value ".bat")
    else()
        set(value "")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

function(get_win_host_batch_file_workaround_prefix out_var)
    set(args "")
    # execute_process can't handle commands with arguments that contain spaces in both the
    # executable path and the arguments, if the executable is a batch script. Work around it
    # by prepending 'cmd /c call', which avoids the issue.
    # See https://gitlab.kitware.com/cmake/cmake/-/issues/26655
    if(CMAKE_HOST_WIN32)
        list(APPEND args "cmd" "/c" "call")
    endif()
endfunction()

# Some common cmake args for configuring qt and standalone tests / examples.
function(get_common_cmake_args out_var)
    set(use_ccache_option "")
    get_cmake_or_env_or_default(use_ccache QT_CI_BUILD_QT_USE_CCACHE "ON")
    find_program(CCACHE_EXECUTABLE ccache)
    if(CCACHE_EXECUTABLE AND use_ccache)
        set(use_ccache_option -DQT_USE_CCACHE=ON)
    endif()

    set(common_cmake_args
        ${use_ccache_option}
        -DWARNINGS_ARE_ERRORS=OFF
        -DQT_GENERATE_SBOM=OFF
        # When 6.x.y version bumps are not merged in DAG-dependency order, this avoids
        # blocking integrations due to mismatched package versions.
        -DQT_NO_PACKAGE_VERSION_INCOMPATIBLE_WARNING=ON
        # Avoid using too much disk space.
        -DBUILD_WITH_PCH=OFF
        --log-level STATUS
    )

    # Get the common CI args, to set the sccache args, etc.
    get_cmake_or_env_or_default(ci_common_cmake_args COMMON_CMAKE_ARGS "")
    if(ci_common_cmake_args)
        separate_arguments(ci_common_cmake_args NATIVE_COMMAND ${ci_common_cmake_args})
    endif()
    if(ci_common_cmake_args)
        list(APPEND common_cmake_args ${ci_common_cmake_args})
    endif()

    set(${out_var} "${common_cmake_args}" PARENT_SCOPE)
endfunction()

# Configures a qt repo, either as per-repo or top-level.
# Handles qtbase vs top-level vs other repo case.
# Handles no-prefix builds.
# Configure is not re-ran un repeated test runs, to speed up test runs. Re-configuring can be
# forced by removing the CMakeCache.txt file.
# Passes some additional options like no-pch and no-sbom.
# Uses ccache when available.
function(configure_qt)
    set(opt_args
        USE_QT_CONFIGURE_MODULE
        TOP_LEVEL
        NO_PREFIX
    )
    set(single_args
        TEST_NAME
        CMAKE_GENERATOR
        BUILD_DIR_ROOT_PATH
        REPO_NAME
        REPO_PATH
        INSTALL_PREFIX
        TOP_LEVEL_SOURCE_DIR_PATH
    )
    set(multi_args
        CONFIGURE_ARGS
        CMAKE_ARGS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    check_and_set_common_qt_configure_options()

    if(NOT arg_TOP_LEVEL_SOURCE_DIR_PATH)
        message(FATAL_ERROR "TOP_LEVEL_SOURCE_DIR_PATH is required.")
    endif()

    set(source_dir "${arg_TOP_LEVEL_SOURCE_DIR_PATH}")

    if(arg_TOP_LEVEL)
        set(build_dir_path "${build_dir_root}")
    else()
        set(build_dir_path "${build_dir_root}/${repo_name}")
    endif()
    file(MAKE_DIRECTORY "${build_dir_path}")

    message(STATUS "Configuring: ${test_name}")

    if(EXISTS "${build_dir_path}/CMakeCache.txt")
        message(STATUS "Skipping configuring '${repo_name}' for ${test_name} in "
            "${build_dir_path} as it is already configured. Remove the build dir or the "
            "CMakeCache.txt file to re-configure.")
        return()
    endif()

    if(arg_NO_PREFIX)
        # In a no-prefix build, the prefix is the qtbase build dir.
        set(install_prefix "${build_dir_root}/qtbase")
        set(install_prefix_option -no-prefix)
    elseif(arg_INSTALL_PREFIX)
        set(install_prefix "${arg_INSTALL_PREFIX}")
        set(install_prefix_option -prefix "${arg_INSTALL_PREFIX}")
    endif()

    if(repo_name STREQUAL "qtbase" OR arg_TOP_LEVEL)
        set(repo_path_option "")
        set(use_qt_configure_module FALSE)
    else()
        set(repo_path_option "${repo_path}")
        set(use_qt_configure_module TRUE)
    endif()

    set(bin_dir "bin")
    get_executable_suffix(executable_suffix)
    get_win_host_batch_file_workaround_prefix(exec_prefix)

    if(arg_TOP_LEVEL)
        set(configure_path "${source_dir}/configure${executable_suffix}")
    elseif(use_qt_configure_module)
        set(configure_path "${install_prefix}/${bin_dir}/qt-configure-module${executable_suffix}")
    else()
        # qtbase case.
        set(configure_path "${source_dir}/${repo_name}/configure${executable_suffix}")
    endif()

    if(arg_CMAKE_GENERATOR)
        set(cmake_generator -G "${arg_CMAKE_GENERATOR}")
    else()
        set(cmake_generator -G "${RunCMake_GENERATOR}")
    endif()

    set(initial_configure_args
        ${install_prefix_option}
        -release
    )
    set(initial_cmake_args "")
    set(common_configure_args
        ${exec_prefix}
        "${configure_path}"
        ${repo_path_option}
        ${arg_CONFIGURE_ARGS}
    )
    get_common_cmake_args(common_cmake_args)
    list(APPEND common_cmake_args
        ${cmake_generator}
        ${arg_CMAKE_ARGS}
    )

    set(final_configure_args ${common_configure_args})
    if(repo_name STREQUAL "qtbase" OR arg_TOP_LEVEL)
        list(APPEND final_configure_args ${initial_configure_args})
    endif()

    set(final_cmake_args ${common_cmake_args})
    if(repo_name STREQUAL "qtbase" OR arg_TOP_LEVEL)
        list(APPEND final_cmake_args ${initial_cmake_args})
    endif()

    if(final_cmake_args)
        list(APPEND final_configure_args "--" ${final_cmake_args})
    endif()

    # Merge stdout with stderr, to avoid having stderr output trigger errors because the
    # configure mixes writes to both streams.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${build_dir_path}")
    setup_verbose_command_output()
    set(prefix "${test_name}_")
    run_command("${prefix}" configure ${final_configure_args})
endfunction()

function(get_standalone_part_name out_var)
    set(opt_args "")
    set(single_args
        PART_NAME
        PART_VARIANT
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 1 arg "${opt_args}" "${single_args}" "${multi_args}")

    if(NOT arg_PART_NAME)
        message(FATAL_ERROR "PART_NAME is required.")
    endif()

    set(supported_parts TESTS EXAMPLES)
    if(NOT arg_PART_NAME IN_LIST supported_parts)
        message(FATAL_ERROR "PART_NAME must be one of: ${supported_parts}")
    endif()
    string(TOLOWER "${arg_PART_NAME}" part_name)

    string(TOLOWER "${arg_PART_NAME}" part_name)

    if(arg_PART_NAME STREQUAL "EXAMPLES")
        if(NOT arg_PART_VARIANT)
            message(FATAL_ERROR "PART_VARIANT is required for EXAMPLES")
        endif()
        set(supported_examples_part_variant EXAMPLES_IN_TREE EXAMPLES_AS_EXTERNAL_PROJECTS)
        if(NOT arg_PART_VARIANT IN_LIST supported_examples_part_variant)
            message(FATAL_ERROR "PART_VARIANT must be one of: ${supported_examples_part_variant}")
        endif()
        if(arg_PART_VARIANT STREQUAL "EXAMPLES_IN_TREE")
            set(part_variant_suffix "_it")
        elseif(arg_PART_VARIANT STREQUAL "EXAMPLES_AS_EXTERNAL_PROJECTS")
            set(part_variant_suffix "_ep")
        endif()
    endif()
    set(${out_var} "standalone_${part_name}${part_variant_suffix}" PARENT_SCOPE)
endfunction()

# Configures standalone tests or examples for a repo.
function(configure_standalone_part)
    set(opt_args
        TOP_LEVEL
        NO_PREFIX
    )
    set(single_args
        TEST_NAME
        CMAKE_GENERATOR
        BUILD_DIR_ROOT_PATH
        REPO_NAME
        REPO_PATH
        INSTALL_PREFIX
        PART_NAME
        PART_VARIANT
        OUT_VAR_BUILD_DIR
    )
    set(multi_args
        CMAKE_ARGS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    if(NOT arg_PART_NAME)
        message(FATAL_ERROR "PART_NAME is required.")
    endif()
    set(standalone_part_name_args PART_NAME ${arg_PART_NAME})
    if(arg_PART_VARIANT)
        list(APPEND standalone_part_name_args PART_VARIANT ${arg_PART_VARIANT})
    endif()
    get_standalone_part_name(standalone_part_name ${standalone_part_name_args})
    string(TOLOWER "${arg_PART_NAME}" part_name)

    check_and_set_common_qt_configure_options()

    message(STATUS "Configuring standalone parts: ${arg_TEST_NAME}:${repo_name}:${part_name}")

    if(arg_TOP_LEVEL)
        set(build_dir_path "${build_dir_root}/${standalone_part_name}")
    else()
        set(build_dir_path
            "${build_dir_root}/${standalone_part_name}_${repo_name}")
    endif()
    file(MAKE_DIRECTORY "${build_dir_path}")
    set(${arg_OUT_VAR_BUILD_DIR} "${build_dir_path}" PARENT_SCOPE)

    if(EXISTS "${build_dir_path}/CMakeCache.txt")
        message(STATUS "Skipping configuring '${repo_name}' standalone ${part_name} for "
            "${arg_TEST_NAME} in ${build_dir_path} as it is already configured. Remove the build "
            "dir or the CMakeCache.txt file to re-configure.")
        return()
    endif()

    if(arg_NO_PREFIX)
        # In a no-prefix build, the prefix is the qtbase build dir.
        set(install_prefix "${build_dir_root}/qtbase")
    elseif(arg_INSTALL_PREFIX)
        set(install_prefix "${arg_INSTALL_PREFIX}")
    endif()

    get_libexec_dir(libexec_dir)
    get_executable_suffix(executable_suffix)
    get_win_host_batch_file_workaround_prefix(exec_prefix)

    set(libexec_path "${install_prefix}")
    set(configure_script
        "${libexec_path}/${libexec_dir}/qt-internal-configure-${part_name}${executable_suffix}")

    set(common_configure_args
        ${exec_prefix}
        "${configure_script}"
        -S "${repo_path}"
        -B .
    )
    get_common_cmake_args(common_cmake_args)
    if(arg_CMAKE_GENERATOR)
        list(APPEND common_cmake_args -G "${arg_CMAKE_GENERATOR}")
    else()
        list(APPEND common_cmake_args -G "${RunCMake_GENERATOR}")
    endif()
    list(APPEND common_cmake_args
        ${arg_CMAKE_ARGS}
    )

    if(arg_PART_NAME STREQUAL "EXAMPLES")
        if(arg_PART_VARIANT STREQUAL "EXAMPLES_IN_TREE")
            set(variant_value "OFF")
        else()
            set(variant_value "ON")
        endif()
        list(APPEND common_configure_args -DQT_BUILD_EXAMPLES_AS_EXTERNAL=${variant_value})
    endif()

    set(final_configure_args "")
    list(APPEND final_configure_args ${common_configure_args})

    set(final_cmake_args "")
    list(APPEND final_cmake_args ${common_cmake_args})

    if(final_cmake_args)
        list(APPEND final_configure_args ${final_cmake_args})
    endif()

    # Merge stdout with stderr, to avoid having stderr output trigger errors because the
    # configure mixes writes to both streams.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${build_dir_path}")
    setup_verbose_command_output()
    set(prefix "${test_name}_")
    run_command("${prefix}" "configure_${part_name}" ${final_configure_args})

    set(${arg_OUT_VAR_BUILD_DIR} "${build_dir_path}" PARENT_SCOPE)
endfunction()

# Calls cmake in the given directory.
function(call_cmake_in_dir)
    set(opt_args "")
    set(single_args
        TEST_NAME
        OP_NAME
        BUILD_DIR_PATH
        LOG_LEVEL
    )
    set(multi_args
        CMAKE_ARGS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    set(prefix "${arg_TEST_NAME}_")

    if(NOT arg_BUILD_DIR_PATH)
        message(FATAL_ERROR "BUILD_DIR_PATH is required.")
    endif()
    set(build_dir_path "${arg_BUILD_DIR_PATH}")

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${build_dir_path}")
    message(STATUS "Calling cmake: ${arg_TEST_NAME}:${build_dir_path}")

    setup_verbose_command_output()

    if(arg_OP_NAME)
        set(op_name "${arg_OP_NAME}")
    else()
        set(op_name "cmake")
    endif()


    set(extra_cmake_args ${arg_CMAKE_ARGS})
    if(arg_LOG_LEVEL)
        list(APPEND extra_cmake_args "--log-level=${arg_LOG_LEVEL}")
    endif()

    # Merge stdout with stderr, to avoid having stderr output when configure is re-ran as part of
    # the build.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    run_command("${prefix}" ${op_name}
        ${CMAKE_COMMAND}
            .
            ${extra_cmake_args}
    )
endfunction()

function(call_cmake_in_qt_build_dir)
    set(opt_args
        TOP_LEVEL
    )
    set(single_args
        TEST_NAME
        BUILD_DIR_ROOT_PATH
        REPO_NAME
        REPO_PATH
        LOG_LEVEL
        STANDALONE_PART_PREFIX
    )
    set(multi_args
        CMAKE_ARGS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    check_and_set_common_qt_configure_options()

    set(repo_prefix "")
    if(arg_STANDALONE_PART)
        set(repo_prefix "${arg_STANDALONE_PART_PREFIX}_")
    endif()

    if(arg_TOP_LEVEL)
        set(build_dir_path "${build_dir_root}")
    else()
        set(build_dir_path "${build_dir_root}/${repo_prefix}${repo_name}")
    endif()

    set(op_name "cmake_in_qt")

    set(extra_cmake_args "")
    if(arg_CMAKE_ARGS)
        list(APPEND extra_cmake_args ${arg_CMAKE_ARGS})
    endif()

    if(arg_LOG_LEVEL)
        list(APPEND extra_cmake_args LOG_LEVEL "${arg_LOG_LEVEL}")
    endif()

    if(extra_cmake_args)
        set(extra_cmake_args CMAKE_ARGS ${extra_cmake_args})
    endif()

    call_cmake_in_dir(
        TEST_NAME "${test_name}"
        BUILD_DIR_PATH "${build_dir_path}"
        OP_NAME "${op_name}"
        ${extra_cmake_args}
    )
endfunction()

# Calls cmake --build in the given directory.
function(build_in_dir)
    set(opt_args
        BUILD_VERBOSE
        BUILD_NINJA_EXPLAIN
    )
    set(single_args
        TEST_NAME
        OP_NAME
        BUILD_DIR_PATH
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    set(prefix "${arg_TEST_NAME}_")

    if(NOT arg_BUILD_DIR_PATH)
        message(FATAL_ERROR "BUILD_DIR_PATH is required.")
    endif()
    set(build_dir_path "${arg_BUILD_DIR_PATH}")

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${build_dir_path}")
    message(STATUS "Building: ${arg_TEST_NAME}:${build_dir_path}")

    setup_verbose_command_output()

    if(arg_OP_NAME)
        set(op_name "${arg_OP_NAME}")
    else()
        set(op_name "build")
    endif()

    # Merge stdout with stderr, to avoid having stderr output when configure is re-ran as part of
    # the build.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    set(build_args
        ${CMAKE_COMMAND}
        --build .
        --parallel
    )

    if(arg_BUILD_VERBOSE)
        list(APPEND build_args --verbose)
    endif()

    set(build_tool_args "")

    if(arg_BUILD_NINJA_EXPLAIN)
        list(APPEND build_tool_args -d explain)
    endif()

    if(build_tool_args)
        list(APPEND build_args -- ${build_tool_args})
    endif()

    run_command("${prefix}" ${op_name} ${build_args})
endfunction()

# Builds a qt repo.
function(build_qt)
    set(opt_args
        TOP_LEVEL
        IS_REBUILD
        BUILD_VERBOSE
        BUILD_NINJA_EXPLAIN
    )
    set(single_args
        TEST_NAME
        REPO_NAME
        REPO_PATH
        BUILD_DIR_ROOT_PATH
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    check_and_set_common_qt_configure_options()

    if(arg_TOP_LEVEL)
        set(build_dir_path "${build_dir_root}")
    else()
        set(build_dir_path "${build_dir_root}/${repo_name}")
    endif()

    if(arg_IS_REBUILD)
        set(op_name "rebuild_qt")
    else()
        set(op_name "build_qt")
    endif()

    set(extra_build_args "")
    if(arg_BUILD_VERBOSE)
        list(APPEND extra_build_args BUILD_VERBOSE)
    endif()

    if(arg_BUILD_NINJA_EXPLAIN)
        list(APPEND extra_build_args BUILD_NINJA_EXPLAIN)
    endif()

    build_in_dir(
        TEST_NAME "${test_name}"
        BUILD_DIR_PATH "${build_dir_path}"
        OP_NAME "${op_name}"
        ${extra_build_args}
    )
endfunction()

# Installs a qt repo.
# Is a no-op for no-prefix builds.
function(install_qt)
    set(opt_args
        TOP_LEVEL
        NO_PREFIX
    )
    set(single_args
        TEST_NAME
        REPO_NAME
        REPO_PATH
        BUILD_DIR_ROOT_PATH
        INSTALL_PREFIX
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    message(STATUS "Installing: ${arg_TEST_NAME}")

    if(arg_NO_PREFIX)
        # Installation is a no-op for no-prefix builds.
        message(STATUS "Skipping installation for ${arg_TEST_NAME} because it's a no-prefix build.")
        return()
    endif()

    check_and_set_common_qt_configure_options()

    set(prefix "${test_name}_")
    if(arg_TOP_LEVEL)
        set(build_dir_path "${build_dir_root}")
    else()
        set(build_dir_path "${build_dir_root}/${repo_name}")
    endif()

    get_libexec_dir(libexec_dir)

    if(arg_TOP_LEVEL)
        set(libexec_path "${build_dir_path}/qtbase")
    elseif(repo_name STREQUAL "qtbase")
        set(libexec_path "${build_dir_path}")
    else()
        set(libexec_path "${arg_INSTALL_PREFIX}")
    endif()
    set(install_script "${libexec_path}/${libexec_dir}/qt-cmake-private-install.cmake")

    # Merge stdout with stderr, to avoid having stderr output when runinng install_name_tool on
    # test reruns on macOS.
    set(RunCMake_TEST_OUTPUT_MERGE TRUE)

    set(RunCMake_TEST_COMMAND_WORKING_DIRECTORY "${build_dir_path}")
    setup_verbose_command_output()
    run_command("${prefix}" install
        ${CMAKE_COMMAND}
            "-DQT_BUILD_DIR=${build_dir_path}"
            -P "${install_script}"
    )
endfunction()

# A helper to configure build and install a list of qt repos (or top-level).
# Also configures and builds standalone tests and examples, or in-tree tests and examples.
# Handles no-prefix builds, top-level builds, in-source builds.
function(qt_build_helper)
    set(opt_args
        NO_PREFIX
        IN_SOURCE
        TOP_LEVEL
        BUILD_STANDALONE_TESTS
        BUILD_STANDALONE_EXAMPLES_IN_TREE
        BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS
        BUILD_IN_TREE_TESTS
        BUILD_IN_TREE_EXAMPLES
        SKIP_STANDALONE_PARTS
        RECONFIGURE_WITHOUT_ARGS_AFTER_BUILD
        RECONFIGURE_WITHOUT_ARGS_IMMEDIATELY
        BUILD_AFTER_RECONFIGURE
        RECONFIGURE_STANDALONE_PARTS
    )
    set(single_args
        TEST_NAME
        BUILD_DIR_NAME
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    if(NOT arg_TEST_NAME)
        message(FATAL_ERROR "TEST_NAME is required.")
    endif()

    if(NOT arg_BUILD_DIR_NAME)
        set(arg_BUILD_DIR_NAME "${arg_TEST_NAME}")
    endif()

    message(STATUS "Running test: ${arg_TEST_NAME}")

    set(repos ${QT_BUILD_SUBMODULES})
    set(repos_to_skip ${QT_SKIP_SUBMODULES})
    set(build_dir_root "${BUILDS_PATH}/${arg_BUILD_DIR_NAME}")
    set(install_prefix "${BUILDS_PATH}/${arg_BUILD_DIR_NAME}/installed")

    if(arg_IN_SOURCE)
        set(source_dir "${build_dir_root}")
        copy_qt_sources(
            DESTINATION_PATH "${source_dir}"
        )
    else()
        set(source_dir "${TOP_LEVEL_SRC_DIR}")
    endif()

    set(extra_args "")
    if(arg_NO_PREFIX)
        list(APPEND extra_args
            NO_PREFIX
        )
    else()
        list(APPEND extra_args
            INSTALL_PREFIX "${install_prefix}"
        )
    endif()

    set(extra_cmake_args "")
    if(arg_TOP_LEVEL)
        set(repos_to_process "qt6")

        # Explicit skip configuring skipped repos for top-level builds.
        foreach(repo_to_skip IN LISTS repos_to_skip)
            list(APPEND extra_cmake_args "-DBUILD_${repo_to_skip}=OFF")
        endforeach()

        list(APPEND extra_args TOP_LEVEL)
    else()
        set(repos_to_process ${repos})
    endif()

    foreach(repo_name IN LISTS repos_to_process)
        if(NOT arg_TOP_LEVEL)
            # For per-repo builds, we just skip calling configure.
            if(repo_name IN_LIST repos_to_skip)
                message(STATUS "Skipping building ${repo_name}")
                continue()
            endif()
        endif()

        if(arg_TOP_LEVEL)
            set(repo_path "${source_dir}")
            set(test_name "${arg_TEST_NAME}")
        else()
            set(repo_path "${source_dir}/${repo_name}")
            set(test_name "${arg_TEST_NAME}_${repo_name}")
        endif()

        set(common_args
            TEST_NAME "${test_name}"
            REPO_NAME "${repo_name}"
            REPO_PATH "${repo_path}"
            TOP_LEVEL_SOURCE_DIR_PATH "${source_dir}"
            BUILD_DIR_ROOT_PATH "${build_dir_root}"
            ${extra_args}
        )

        set(common_cmake_args ${extra_cmake_args})

        set(build_in_tree_tests OFF)
        if(arg_BUILD_IN_TREE_TESTS)
            set(build_in_tree_tests ON)
        endif()

        set(build_in_tree_examples OFF)
        if(arg_BUILD_IN_TREE_EXAMPLES)
            set(build_in_tree_examples ON)
            list(APPEND common_cmake_args -DQT_BUILD_EXAMPLES_AS_EXTERNAL=OFF)
        endif()

        list(APPEND common_cmake_args
            -DQT_BUILD_TESTS=${build_in_tree_tests}
            -DQT_BUILD_EXAMPLES=${build_in_tree_examples}
        )

        set(common_args_with_cmake_args ${common_args})
        if(common_cmake_args)
            list(APPEND common_args_with_cmake_args
                CMAKE_ARGS ${common_cmake_args}
            )
        endif()

        configure_qt(${common_args_with_cmake_args})

        if(arg_RECONFIGURE_WITHOUT_ARGS_IMMEDIATELY)
            call_cmake_in_qt_build_dir(
                ${common_args}
                LOG_LEVEL STATUS
            )
        endif()

        build_qt(${common_args})

        if(arg_RECONFIGURE_WITHOUT_ARGS_AFTER_BUILD)
            call_cmake_in_qt_build_dir(
                ${common_args}
                LOG_LEVEL STATUS
            )
        endif()

        if(arg_BUILD_AFTER_RECONFIGURE)
            build_qt(
                IS_REBUILD
                BUILD_VERBOSE
                BUILD_NINJA_EXPLAIN
                ${common_args}
            )
        endif()

        install_qt(${common_args_with_cmake_args})

        if(arg_BUILD_STANDALONE_TESTS AND NOT arg_SKIP_STANDALONE_PARTS)
            configure_standalone_part(
                ${common_args_with_cmake_args}
                PART_NAME "TESTS"
                OUT_VAR_BUILD_DIR tests_build_dir
            )
            build_in_dir(
                TEST_NAME "${test_name}"
                BUILD_DIR_PATH "${tests_build_dir}"
                OP_NAME "build_tests"
            )
            if(arg_RECONFIGURE_STANDALONE_PARTS)
                get_standalone_part_name(standalone_part_name
                    PART_NAME "TESTS"
                )
                call_cmake_in_qt_build_dir(
                    ${common_args}
                    LOG_LEVEL STATUS
                    STANDALONE_PART_PREFIX "${standalone_part_name}"
                )
            endif()
        endif()

        if(arg_BUILD_STANDALONE_EXAMPLES_IN_TREE AND NOT arg_SKIP_STANDALONE_PARTS)
            configure_standalone_part(
                ${common_args_with_cmake_args}
                PART_NAME "EXAMPLES"
                PART_VARIANT "EXAMPLES_IN_TREE"
                OUT_VAR_BUILD_DIR examples_build_dir
            )
            build_in_dir(
                TEST_NAME "${test_name}"
                BUILD_DIR_PATH "${examples_build_dir}"
                OP_NAME "build_examples"
            )
            if(arg_RECONFIGURE_STANDALONE_PARTS)
                get_standalone_part_name(standalone_part_name
                    PART_NAME "EXAMPLES"
                    PART_VARIANT "EXAMPLES_IN_TREE"
                )
                call_cmake_in_qt_build_dir(
                    ${common_args}
                    LOG_LEVEL STATUS
                    STANDALONE_PART_PREFIX "${standalone_part_name}"
                )
            endif()
        endif()

        if(arg_BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS AND NOT arg_SKIP_STANDALONE_PARTS)
            configure_standalone_part(
                ${common_args_with_cmake_args}
                PART_NAME "EXAMPLES"
                PART_VARIANT "EXAMPLES_AS_EXTERNAL_PROJECTS"
                OUT_VAR_BUILD_DIR examples_build_dir
            )
            build_in_dir(
                TEST_NAME "${test_name}"
                BUILD_DIR_PATH "${examples_build_dir}"
                OP_NAME "build_examples"
            )
            if(arg_RECONFIGURE_STANDALONE_PARTS)
                get_standalone_part_name(standalone_part_name
                    PART_NAME "EXAMPLES"
                    PART_VARIANT "EXAMPLES_AS_EXTERNAL_PROJECTS"
                )
                call_cmake_in_qt_build_dir(
                    ${common_args}
                    LOG_LEVEL STATUS
                    STANDALONE_PART_PREFIX "${standalone_part_name}"
                )
            endif()
        endif()
    endforeach()

    # Do another round of reconfigure (and in certain cases rebuild) after all submodules were built
    # This will include any plugin navigations in the find_package calls
    if(arg_RECONFIGURE_WITHOUT_ARGS_IMMEDIATELY
        OR arg_RECONFIGURE_WITHOUT_ARGS_AFTER_BUILD)
        foreach(repo_name IN LISTS repos_to_process)
            set(repo_path "${source_dir}/${repo_name}")
            set(test_name "${arg_TEST_NAME}_${repo_name}")

            set(common_args
                TEST_NAME "${test_name}"
                REPO_NAME "${repo_name}"
                REPO_PATH "${repo_path}"
                TOP_LEVEL_SOURCE_DIR_PATH "${source_dir}"
                BUILD_DIR_ROOT_PATH "${build_dir_root}"
                ${extra_args}
            )

            call_cmake_in_qt_build_dir(
                ${common_args}
                LOG_LEVEL STATUS
            )

            if(arg_BUILD_AFTER_RECONFIGURE)
                build_qt(
                    IS_REBUILD
                    BUILD_VERBOSE
                    BUILD_NINJA_EXPLAIN
                    ${common_args}
                )
            endif()
            if(arg_RECONFIGURE_STANDALONE_PARTS AND NOT arg_SKIP_STANDALONE_PARTS)
                if(arg_BUILD_STANDALONE_TESTS)
                    get_standalone_part_name(standalone_part_name
                        PART_NAME "TESTS"
                    )
                    call_cmake_in_qt_build_dir(
                        ${common_args}
                        LOG_LEVEL STATUS
                        STANDALONE_PART_PREFIX "${standalone_part_name}"
                    )
                endif()

                if(arg_BUILD_STANDALONE_EXAMPLES_IN_TREE)
                    get_standalone_part_name(standalone_part_name
                        PART_NAME "EXAMPLES"
                        PART_VARIANT "EXAMPLES_IN_TREE"
                    )
                    call_cmake_in_qt_build_dir(
                        ${common_args}
                        LOG_LEVEL STATUS
                        STANDALONE_PART_PREFIX "${standalone_part_name}"
                    )
                endif()

                if(arg_BUILD_STANDALONE_EXAMPLES_AS_EXTERNAL_PROJECTS)
                    get_standalone_part_name(standalone_part_name
                        PART_NAME "EXAMPLES"
                        PART_VARIANT "EXAMPLES_AS_EXTERNAL_PROJECTS"
                    )
                    call_cmake_in_qt_build_dir(
                        ${common_args}
                        LOG_LEVEL STATUS
                        STANDALONE_PART_PREFIX "${standalone_part_name}"
                    )
                endif()
            endif()
        endforeach()
    endif()
endfunction()

function(add_test_case)
    set(opt_args "")
    set(single_args
        TEST_NAME
    )
    set(multi_args
        TEST_GROUPS
        TEST_ARGS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")

    if(NOT arg_TEST_NAME)
        message(FATAL_ERROR "TEST_NAME is required.")
    endif()

    set(test_cases "${TEST_CASES}")
    set(test_groups "${TEST_GROUPS}")

    list(APPEND test_cases "${arg_TEST_NAME}")
    if(arg_TEST_GROUPS)
        list(APPEND test_groups "${arg_TEST_GROUPS}")
        list(REMOVE_DUPLICATES test_groups)
        foreach(group IN LISTS arg_TEST_GROUPS)
            set(group_cases ${TEST_GROUPS_${group}})
            list(APPEND group_cases "${arg_TEST_NAME}")
            set(TEST_GROUPS_${group} "${group_cases}")
            set(TEST_GROUPS_${group} "${group_cases}" PARENT_SCOPE)
        endforeach()
    endif()

    set(TESTS_${arg_TEST_NAME}_ARGS ${arg_TEST_ARGS} PARENT_SCOPE)

    set(TEST_CASES "${test_cases}" PARENT_SCOPE)
    set(TEST_GROUPS "${test_groups}" PARENT_SCOPE)
endfunction()

macro(setup_qt_sources_and_repos_to_build)
    setup_qt_repos_to_clone()
    setup_qt_sources()
    setup_list_of_repos_to_build()
endmacro()

# Applies a filter to the collected test cases from the QT_CI_BUILD_QT_TESTS cmake or env var.
# The filter is a comma separated list of one of the following:
# 'all' to include all tests
# 'test case name' to include a specific test
# 'group name' to include all tests in a specific group
# '-all' to exclude all tests
# '-test case name' to exclude a specific test
# '-group name' to exclude all tests in a specific group
# '-standalone_parts' to exclude building standalone tests and examples for all tests
# The values are processed in the order they appear.
# Default is all.
macro(apply_filter_to_collected_tests)
    get_cmake_or_env_or_default(cases_filter QT_CI_BUILD_QT_FILTER "all")
    # Allow both semicolons and commas.
    string(REPLACE "," ";" cases_filter "${cases_filter}")

    message(STATUS "Applying filter: ${cases_filter}")

    # Validate filters.
    set(special_filters
        all
        standalone_parts
    )
    foreach(filter IN LISTS cases_filter)
        set(clean_filter "${filter}")
        if(filter MATCHES "^-")
            string(SUBSTRING "${filter}" 1 -1 clean_filter)
        endif()
        if(NOT clean_filter IN_LIST TEST_CASES
                AND NOT clean_filter IN_LIST TEST_GROUPS
                AND NOT clean_filter IN_LIST special_filters)
            message(FATAL_ERROR "Invalid filter: ${filter}")
        endif()
    endforeach()

    set(TEST_CASES_FINAL "")

    # Allow configuring which test cases to run.
    foreach(test_name IN LISTS TEST_CASES)
        set(include_test_case FALSE)
        foreach(filter IN LISTS cases_filter)
            set(clean_group_name "${filter}")
            if(filter MATCHES "^-")
                string(SUBSTRING "${filter}" 1 -1 clean_group_name)
            endif()

            if(
                    # Check if exact test case is included
                    test_name STREQUAL filter

                    # Check if all test cases should be run
                    OR filter STREQUAL "all"

                    # Check if test case is in a specific filter group
                    OR test_name IN_LIST TEST_GROUPS_${filter}
                    )
                set(include_test_case TRUE)
            endif()

            if(
                    # Check if test case is explicitly excluded
                    "-${test_name}" STREQUAL "${filter}"

                    # Check if all test cases should be excluded
                    OR filter STREQUAL "-all"

                    # Check if specific group is excluded
                    OR (filter MATCHES "^-"
                        AND test_name IN_LIST TEST_GROUPS_${clean_group_name})
                )
                set(include_test_case FALSE)
            endif()
        endforeach()
        if(include_test_case)
            list(APPEND TEST_CASES_FINAL "${test_name}")
        endif()
    endforeach()


    if("-standalone_parts" IN_LIST cases_filter)
        set(SKIP_STANDALONE_PARTS SKIP_STANDALONE_PARTS)
    endif()
endmacro()

# Runs the full suite of tests for building Qt.
function(run_tests)
    setup_qt_sources_and_repos_to_build()

    collect_tests()
    apply_filter_to_collected_tests()

    set(no_cases "")
    if(NOT TEST_CASES_FINAL)
        set(no_cases "No test cases to run.")
    endif()

    message(STATUS "Running test cases: ${TEST_CASES_FINAL}${no_cases}")
    foreach(test_name IN LISTS TEST_CASES_FINAL)
        qt_build_helper(
            TEST_NAME "${test_name}"
            ${TESTS_${test_name}_ARGS}
            ${SKIP_STANDALONE_PARTS}
        )
    endforeach()
endfunction()
