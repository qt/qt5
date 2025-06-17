# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

macro(qt_tl_include_all_helpers)
    include(QtIRHelpers)
    qt_ir_include_all_helpers()
endmacro()

function(qt_tl_run_toplevel_configure top_level_src_path)
    cmake_parse_arguments(arg "ALREADY_INITIALIZED" "" "" ${ARGV})

    qt_ir_get_cmake_flag(ALREADY_INITIALIZED arg_ALREADY_INITIALIZED)

    # Filter out init-repository specific arguments before passing them to
    # configure.
    qt_ir_get_args_from_optfile_configure_filtered("${OPTFILE}" configure_args
        ${arg_ALREADY_INITIALIZED})
    # Get the path to the qtbase configure script.
    set(qtbase_dir_name "qtbase")
    set(configure_path "${top_level_src_path}/${qtbase_dir_name}/configure")
    if(CMAKE_HOST_WIN32)
        string(APPEND configure_path ".bat")
    endif()

    if(NOT EXISTS "${configure_path}")
        message(FATAL_ERROR
            "The required qtbase/configure script was not found: ${configure_path}\n"
            "Try re-running configure with --init-submodules")
    endif()

    # Make a build directory for qtbase in the current build directory.
    set(qtbase_build_dir "${CMAKE_CURRENT_BINARY_DIR}/${qtbase_dir_name}")
    file(MAKE_DIRECTORY "${qtbase_build_dir}")

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS "${configure_path}" -top-level ${configure_args}
        WORKING_DIRECTORY "${qtbase_build_dir}"
        FORCE_VERBOSE
    )
endfunction()

function(qt_tl_run_main_script)
    if(NOT TOP_LEVEL_SRC_PATH)
        message(FATAL_ERROR "Assertion: configure TOP_LEVEL_SRC_PATH is not set")
    endif()

    # Tell init-repository it is called from configure.
    qt_ir_set_option_value(from-configure TRUE)

    # Run init-repository in-process.
    qt_ir_run_main_script("${TOP_LEVEL_SRC_PATH}" exit_reason)
    if(exit_reason AND NOT exit_reason STREQUAL "ALREADY_INITIALIZED")
        return()
    endif()

    # Then run configure out-of-process.
    qt_tl_run_toplevel_configure("${TOP_LEVEL_SRC_PATH}" ${exit_reason})
endfunction()

# Populates $out_module_list with all subdirectories that have a CMakeLists.txt file
function(qt_internal_find_modules out_module_list)
    set(module_list "")
    file(GLOB directories LIST_DIRECTORIES true RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *)
    foreach(directory IN LISTS directories)
        if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${directory}"
           AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${directory}/CMakeLists.txt")
            list(APPEND module_list "${directory}")
        endif()
    endforeach()
    message(DEBUG "qt_internal_find_modules: ${module_list}")
    set(${out_module_list} "${module_list}" PARENT_SCOPE)
endfunction()

# poor man's yaml parser, populating $out_dependencies with all dependencies
# in the $depends_file
# Each entry will be in the format dependency/sha1/required
function(qt_internal_parse_dependencies_yaml depends_file out_dependencies)
    file(STRINGS "${depends_file}" lines)
    set(eof_marker "---EOF---")
    list(APPEND lines "${eof_marker}")
    set(required_default TRUE)
    set(dependencies "")
    set(dependency "")
    set(revision "")
    set(required "${required_default}")
    foreach(line IN LISTS lines)
        if(line MATCHES "^  (.+):$" OR line STREQUAL "${eof_marker}")
            # Found a repo entry or end of file. Add the last seen dependency.
            if(NOT dependency STREQUAL "")
                if(revision STREQUAL "")
                    message(FATAL_ERROR "Format error in ${depends_file} - ${dependency} does not specify revision!")
                endif()
                list(APPEND dependencies "${dependency}/${revision}/${required}")
            endif()
            # Remember the current dependency
            if(NOT line STREQUAL "${eof_marker}")
                set(dependency "${CMAKE_MATCH_1}")
                set(revision "")
                set(required "${required_default}")
                # dependencies are specified with relative path to this module
                string(REPLACE "../" "" dependency ${dependency})
            endif()
        elseif(line MATCHES "^    ref: (.+)$")
            set(revision "${CMAKE_MATCH_1}")
        elseif(line MATCHES "^    required: (.+)$")
            string(TOUPPER "${CMAKE_MATCH_1}" required)
        endif()
    endforeach()
    message(DEBUG
        "qt_internal_parse_dependencies_yaml for ${depends_file}\n    dependencies: ${dependencies}")
    set(${out_dependencies} "${dependencies}" PARENT_SCOPE)
endfunction()

# Helper macro for qt_internal_resolve_module_dependencies.
macro(qt_internal_resolve_module_dependencies_set_skipped value)
    if(DEFINED arg_SKIPPED_VAR)
        set(${arg_SKIPPED_VAR} ${value} PARENT_SCOPE)
    endif()
endmacro()

# Strips tqtc- prefix from a repo name.
function(qt_internal_normalize_repo_name repo_name out_var)
    string(REGEX REPLACE "^tqtc-" "" normalized "${repo_name}")
    set(${out_var} "${normalized}" PARENT_SCOPE)
endfunction()

# Checks if a directory with the given repo name exists in the current
# source / working directory. If it doesn't, it strips the tqtc- prefix.
function(qt_internal_use_normalized_repo_name_if_needed repo_name out_var)
    set(base_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(repo_dir "${base_dir}/${repo_name}")
    if(NOT IS_DIRECTORY "${repo_dir}")
        qt_internal_normalize_repo_name("${repo_name}" repo_name)
    endif()
    set(${out_var} "${repo_name}" PARENT_SCOPE)
endfunction()


# Resolve the dependencies of the given module.
# "Module" in the sense of Qt repository.
#
# Side effects: Sets the global properties QT_DEPS_FOR_${module} and QT_REQUIRED_DEPS_FOR_${module}
# with the direct (required) dependencies of module.
#
#
# Positional arguments:
#
# module is the Qt repository.
#
# out_ordered is where the result is stored. This is a list of all dependencies, including
# transitive ones, in topologically sorted order. Note that ${module} itself is also part of
# out_ordered.
#
# out_revisions is a list of git commit IDs for each of the dependencies in ${out_ordered}. This
# list has the same length as ${out_ordered}.
#
#
# Keyword arguments:
#
# PARSED_DEPENDENCIES is a list of dependencies of module in the format that
# qt_internal_parse_dependencies_yaml returns.
# If this argument is not provided, either a module's dependencies.yaml or .gitmodules file is
# used as the source of dependencies, depending on whether PARSE_GITMODULES option is enabled.
#
# PARSE_GITMODULES is a boolean that controls whether the .gitmodules or the dependencies.yaml
# file of the repo are used for extracting dependencies. Defaults to FALSE, so uses
# dependencies.yaml by default.
#
# EXCLUDE_OPTIONAL_DEPS is a boolean that controls whether optional dependencies are excluded from
# the final result.
#
# EXCLUDE_OPTIONAL_DEPS_VAR is an output variable where to save the list of optional dependencies
# that were excluded due to EXCLUDE_OPTIONAL_DEPS.
#
# GITMODULES_PREFIX_VAR is the prefix of all the variables containing dependencies for the
# PARSE_GITMODULES mode.
# The function expects the following variables to be set in the parent scope
#  ${arg_GITMODULES_PREFIX_VAR}_${submodule_name}_depends
#  ${arg_GITMODULES_PREFIX_VAR}_${submodule_name}_recommends
#
# IN_RECURSION is an internal option that is set when the function is in recursion.
#
# REVISION is an internal value with the git commit ID that belongs to ${module}.
#
# SKIPPED_VAR is an output variable name that is set to TRUE if the module was skipped, to FALSE
# otherwise.
#
# NORMALIZE_REPO_NAME_IF_NEEDED Will remove 'tqtc-' from the beginning of submodule dependencies
# if a tqtc- named directory does not exist.
#
# SKIP_MODULES Modules that should be skipped from evaluation completely.
function(qt_internal_resolve_module_dependencies module out_ordered out_revisions)
    set(options IN_RECURSION NORMALIZE_REPO_NAME_IF_NEEDED PARSE_GITMODULES
                EXCLUDE_OPTIONAL_DEPS)
    set(oneValueArgs REVISION SKIPPED_VAR GITMODULES_PREFIX_VAR EXCLUDE_OPTIONAL_DEPS_VAR)
    set(multiValueArgs PARSED_DEPENDENCIES SKIP_MODULES)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Clear the property that stores the repositories we've already seen.
    if(NOT arg_IN_RECURSION)
        set_property(GLOBAL PROPERTY _qt_internal_seen_repos)
    endif()

    # Bail out if we've seen the module already or it was skipped explicitly from command line.
    qt_internal_resolve_module_dependencies_set_skipped(FALSE)
    get_property(seen GLOBAL PROPERTY _qt_internal_seen_repos)
    if(module IN_LIST seen OR module IN_LIST arg_SKIP_MODULES)
        qt_internal_resolve_module_dependencies_set_skipped(TRUE)
        return()
    endif()

    set_property(GLOBAL APPEND PROPERTY _qt_internal_seen_repos ${module})

    # Set a default REVISION.
    if("${arg_REVISION}" STREQUAL "")
        set(arg_REVISION HEAD)
    endif()

    # Retrieve the dependencies.
    if(DEFINED arg_PARSED_DEPENDENCIES)
        set(dependencies "${arg_PARSED_DEPENDENCIES}")
    else()
        set(dependencies "")

        if(NOT arg_PARSE_GITMODULES)
            set(depends_file "${CMAKE_CURRENT_SOURCE_DIR}/${module}/dependencies.yaml")
            if(EXISTS "${depends_file}")
                qt_internal_parse_dependencies_yaml("${depends_file}" dependencies)

                if(arg_EXCLUDE_OPTIONAL_DEPS)
                    set(filtered_dependencies "")
                    foreach(dependency IN LISTS dependencies)
                        string(REPLACE "/" ";" dependency_split "${dependency}")
                        list(GET dependency_split 2 required)
                        if(required)
                            list(APPEND filtered_dependencies "${dependency}")
                        elseif(arg_EXCLUDE_OPTIONAL_DEPS_VAR)
                            # Add any potentially skipped dependency to the list and
                            # filter out the required ones later
                            list(GET dependency_split 0 dependency_name)
                            list(APPEND ${arg_EXCLUDE_OPTIONAL_DEPS_VAR}
                                "${dependency_name}")
                        endif()
                    endforeach()
                    set(dependencies "${filtered_dependencies}")
                endif()
            endif()
        else()
            set(depends "${${arg_GITMODULES_PREFIX_VAR}_${dependency}_depends}")
            foreach(dependency IN LISTS depends)
                if(dependency)
                    # The HEAD value is not really used, but we need to add something.
                    list(APPEND dependencies "${dependency}/HEAD/TRUE")
                endif()
            endforeach()

            set(recommends "${${arg_GITMODULES_PREFIX_VAR}_${dependency}_recommends}")
            if(NOT arg_EXCLUDE_OPTIONAL_DEPS)
                foreach(dependency IN LISTS recommends)
                    if(dependency)
                        list(APPEND dependencies "${dependency}/HEAD/FALSE")
                    endif()
                endforeach()
            endif()
        endif()
    endif()

    # Traverse the dependencies.
    set(ordered)
    set(revisions)
    foreach(dependency IN LISTS dependencies)
        if(dependency MATCHES "(.*)/([^/]+)/([^/]+)")
            set(dependency "${CMAKE_MATCH_1}")
            set(revision "${CMAKE_MATCH_2}")
            set(required "${CMAKE_MATCH_3}")
        else()
            message(FATAL_ERROR "Internal Error: wrong dependency format ${dependency}")
        endif()

        set(normalize_arg "")
        if(arg_NORMALIZE_REPO_NAME_IF_NEEDED)
            qt_internal_use_normalized_repo_name_if_needed("${dependency}" dependency)
            set(normalize_arg "NORMALIZE_REPO_NAME_IF_NEEDED")
        endif()

        set_property(GLOBAL APPEND PROPERTY QT_DEPS_FOR_${module} ${dependency})
        if(required)
            set_property(GLOBAL APPEND PROPERTY QT_REQUIRED_DEPS_FOR_${module} ${dependency})
        endif()

        set(parse_gitmodules "")
        if(arg_PARSE_GITMODULES)
            set(parse_gitmodules "PARSE_GITMODULES")
        endif()

        set(exclude_optional_deps "")
        if(arg_EXCLUDE_OPTIONAL_DEPS)
            set(exclude_optional_deps "EXCLUDE_OPTIONAL_DEPS")
        endif()

        set(exclude_optional_deps_var "")
        if(arg_EXCLUDE_OPTIONAL_DEPS_VAR)
            set(exclude_optional_deps_var
                EXCLUDE_OPTIONAL_DEPS_VAR "${arg_EXCLUDE_OPTIONAL_DEPS_VAR}")
        endif()

        set(extra_options "")
        if(arg_SKIP_MODULES)
            list(APPEND extra_options SKIP_MODULES ${arg_SKIP_MODULES})
        endif()

        qt_internal_resolve_module_dependencies(${dependency} dep_ordered dep_revisions
            REVISION "${revision}"
            SKIPPED_VAR skipped
            IN_RECURSION
            ${normalize_arg}
            ${parse_gitmodules}
            ${exclude_optional_deps}
            ${exclude_optional_deps_var}
            GITMODULES_PREFIX_VAR ${arg_GITMODULES_PREFIX_VAR}
            ${extra_options}
        )
        if(NOT skipped)
            list(APPEND ordered ${dep_ordered})
            list(APPEND revisions ${dep_revisions})
        endif()
    endforeach()

    list(APPEND ordered ${module})
    list(APPEND revisions ${arg_REVISION})
    set(${out_ordered} "${ordered}" PARENT_SCOPE)
    set(${out_revisions} "${revisions}" PARENT_SCOPE)
    if(arg_EXCLUDE_OPTIONAL_DEPS_VAR)
        # Filter out all dependencies that were marked as required and remove any duplicates
        list(REMOVE_DUPLICATES ${arg_EXCLUDE_OPTIONAL_DEPS_VAR})
        list(REMOVE_ITEM ${arg_EXCLUDE_OPTIONAL_DEPS_VAR} ${ordered})
        set(${arg_EXCLUDE_OPTIONAL_DEPS_VAR}
            "${${arg_EXCLUDE_OPTIONAL_DEPS_VAR}}" PARENT_SCOPE)
    endif()
endfunction()

# Resolves the dependencies of the given modules.
# "Module" is here used in the sense of Qt repository.
#
# Returns all dependencies, including transitive ones, in topologically sorted order.
#
# Arguments:
# modules is the initial list of repos.
# out_all_ordered is the variable name where the result is stored.
# PARSE_GITMODULES and GITMODULES_PREFIX_VAR are keyowrd arguments that change the
# source of dependencies parsing from dependencies.yaml to .gitmodules.
# EXCLUDE_OPTIONAL_DEPS is a keyword argument that excludes optional dependencies from the result.
# See qt_internal_resolve_module_dependencies for details.
#
# EXCLUDE_OPTIONAL_DEPS_VAR is an output variable where to save the list of optional dependencies
# that were excluded due to EXCLUDE_OPTIONAL_DEPS.
# See qt_internal_resolve_module_dependencies for details.
#
# SKIP_MODULES Modules that should be skipped from evaluation completely.
#
# See qt_internal_resolve_module_dependencies for side effects.
function(qt_internal_sort_module_dependencies modules out_all_ordered)
    set(options PARSE_GITMODULES EXCLUDE_OPTIONAL_DEPS)
    set(oneValueArgs GITMODULES_PREFIX_VAR EXCLUDE_OPTIONAL_DEPS_VAR)
    set(multiValueArgs SKIP_MODULES)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(parse_gitmodules "")
    if(arg_PARSE_GITMODULES)
        set(parse_gitmodules "PARSE_GITMODULES")
    endif()

    set(exclude_optional_deps "")
    if(arg_EXCLUDE_OPTIONAL_DEPS)
        set(exclude_optional_deps "EXCLUDE_OPTIONAL_DEPS")
    endif()

    set(exclude_optional_deps_var "")
    if(arg_EXCLUDE_OPTIONAL_DEPS_VAR)
        set(exclude_optional_deps_var
            EXCLUDE_OPTIONAL_DEPS_VAR "${arg_EXCLUDE_OPTIONAL_DEPS_VAR}")
    endif()

    # Create a fake repository "all_selected_repos" that has all repositories from the input as
    # required dependency. The format must match what qt_internal_parse_dependencies_yaml produces.
    set(all_selected_repos_as_parsed_dependencies)
    foreach(module IN LISTS modules)
        list(APPEND all_selected_repos_as_parsed_dependencies "${module}/HEAD/FALSE")
    endforeach()

    set(extra_args "")
    if(arg_SKIP_MODULES)
        set(extra_args SKIP_MODULES ${arg_SKIP_MODULES})
    endif()

    qt_internal_resolve_module_dependencies(all_selected_repos ordered unused_revisions
        PARSED_DEPENDENCIES ${all_selected_repos_as_parsed_dependencies}
        NORMALIZE_REPO_NAME_IF_NEEDED
        ${exclude_optional_deps}
        ${exclude_optional_deps_var}
        ${parse_gitmodules}
        GITMODULES_PREFIX_VAR ${arg_GITMODULES_PREFIX_VAR}
        ${extra_args}
    )

    # Drop "all_selected_repos" from the output. It depends on all selected repos, thus it must be
    # the last element in the topologically sorted list.
    list(REMOVE_AT ordered -1)

    message(DEBUG
        "qt_internal_sort_module_dependencies
    input modules: ${modules}\n    topo-sorted:   ${ordered}")
    set(${out_all_ordered} "${ordered}" PARENT_SCOPE)
    if(arg_EXCLUDE_OPTIONAL_DEPS_VAR)
        set(${arg_EXCLUDE_OPTIONAL_DEPS_VAR}
                "${${arg_EXCLUDE_OPTIONAL_DEPS_VAR}}" PARENT_SCOPE)
    endif()
endfunction()

# Checks whether any unparsed arguments have been passed to the function at the call site.
# Use this right after `cmake_parse_arguments`.
function(qt_internal_tl_validate_all_args_are_parsed prefix)
    if(DEFINED ${prefix}_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown arguments: (${${prefix}_UNPARSED_ARGUMENTS})")
    endif()
endfunction()

# If VERBOSE is not set or FALSE in the parent or root scopes, swallow the git output.
# If VERBOSE is true, echo the stdout output, as well as the command run.
function(qt_internal_tl_handle_verbose_git_operations)
    set(swallow_output "") # unless VERBOSE, eat git output, show it in case of error
    if (NOT VERBOSE)
        list(APPEND swallow_output "OUTPUT_VARIABLE" "git_output" "ERROR_VARIABLE" "git_output")
    else()
        list(APPEND swallow_output COMMAND_ECHO STDOUT)
    endif()
    set(swallow_output "${swallow_output}" PARENT_SCOPE)
endfunction()

# Returns true if the current working directory is a super module with a .gitmodules file.
# Likely means it's the qt5.git super repo.
function(qt_internal_tl_is_super_repo out_var)
    execute_process(
        COMMAND "git" "rev-parse" "--show-toplevel"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE top_level_path
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT git_result AND top_level_path AND EXISTS "${top_level_path}/.gitmodules")
        set(result TRUE)
    else()
        set(result FALSE)
    endif()

    set(${out_var} ${result} PARENT_SCOPE)
endfunction()

# Returns whether the given git repo is shallow (cloned with --depth arg).
function(qt_internal_tl_is_git_repo_shallow out_var working_directory)
    message(DEBUG "Checking if repo in '${working_directory}' is shallow")

    execute_process(
        COMMAND "git" "rev-parse" "--is-shallow-repository"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        WORKING_DIRECTORY "${working_directory}"
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(git_result)
        message(FATAL_ERROR
            "Failed to check if repo is shallow in '${working_directory}'\n"
            "stdout: ${git_stdout}\n"
            "stderr: ${git_stderr}")
    endif()

    string(STRIP "${git_stdout}" git_stdout)
    if(git_stdout)
        set(value TRUE)
    else()
        set(value FALSE)
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Returns whether the given refspec is known to the repo in the given working directory.
function(qt_internal_tl_is_git_ref_spec_known out_var refspec working_directory)
    # The funny ^{commit} syntax means the refpsec resolves to a commit, as opposed to a blob or a
    # tree.
    execute_process(
        COMMAND "git" "cat-file" "-e" "${refspec}^{commit}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        WORKING_DIRECTORY "${working_directory}"
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # A non-0 exit code means it doesn't exist.
    if(git_result)
        set(value FALSE)
    else()
        set(value TRUE)
    endif()

    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Unshallow the given git repo.
function(qt_internal_tl_git_unshallow_repo)
    set(opt_args
        SHOW_PROGRESS
    )
    set(single_args
        WORKING_DIRECTORY
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    set(args "")
    if(arg_SHOW_PROGRESS)
        list(APPEND args --progress)
    endif()

    execute_process(
        COMMAND "git" "fetch" "--unshallow" ${args}
        RESULT_VARIABLE git_result
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        ${swallow_output}
    )

    if(git_result)
        message(FATAL_ERROR
            "Failed to unshallow repo in '${arg_WORKING_DIRECTORY}': ${git_stderr}")
    endif()
endfunction()

# Fetches a shallow ref spec (--depth 1) from the given remote.
function(qt_internal_tl_git_fetch_shallow_ref_spec)
    set(opt_args
        SHOW_PROGRESS
        FATAL
    )
    set(single_args
        REMOTE
        REF_SPEC
        WORKING_DIRECTORY
        OUT_VAR_RESULT
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    if(NOT arg_REF_SPEC)
        message(FATAL_ERROR "REF_SPEC is required")
    endif()

    if(NOT arg_REMOTE)
        message(FATAL_ERROR "REMOTE is required")
    endif()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    if(NOT arg_OUT_VAR_RESULT)
        message(FATAL_ERROR "OUT_VAR_RESULT is required")
    endif()

    set(args "")
    if(arg_SHOW_PROGRESS)
        list(APPEND args --progress)
    endif()

    execute_process(
        COMMAND "git" "fetch" "--depth" "1" "${arg_REMOTE}" "${arg_REF_SPEC}" ${args}
        RESULT_VARIABLE git_result
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        ${swallow_output}
    )

    if(git_result)
        set(result FALSE)
        if(arg_FATAL)
            set(message_type FATAL_ERROR)
        else()
            set(message_type DEBUG)
        endif()
        message(${message_type}
            "Failed to fetch shallow ref spec '${arg_REF_SPEC}' "
            "in '${arg_WORKING_DIRECTORY}': ${git_stderr}")
    else()
        set(result TRUE)
    endif()

    if(arg_OUT_VAR_RESULT)
        set("${arg_OUT_VAR_RESULT}" "${result}" PARENT_SCOPE)
    endif()
endfunction()

# Detects if a repo is shallow. If it is, checks if the given ref spec is known. If not, it will
# try to fetch it. If it's still unknown, will try to unshallow the repo.
function(qt_internal_tl_handle_shallow_repo)
    set(opt_args
        SHOW_PROGRESS
    )
    set(single_args
        REF_SPEC
        REMOTE_NAME
        WORKING_DIRECTORY
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    if(NOT arg_REF_SPEC)
        message(FATAL_ERROR "REF_SPEC is required")
    endif()

    if(NOT arg_REMOTE_NAME)
        message(FATAL_ERROR "REMOTE_NAME is required")
    endif()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    qt_internal_tl_is_git_repo_shallow(is_shallow "${arg_WORKING_DIRECTORY}")
    if(NOT is_shallow)
        return()
    endif()

    qt_internal_tl_is_git_ref_spec_known(is_known "${arg_REF_SPEC}" "${arg_WORKING_DIRECTORY}")
    if(is_known)
        return()
    endif()

    set(remote "${arg_REMOTE_NAME}")
    message(DEBUG
        "Fetching with --depth 1 from '${remote}' due to unknown refspec '${arg_REF_SPEC}'")

    set(args "")
    if(arg_SHOW_PROGRESS)
        list(APPEND args SHOW_PROGRESS)
    endif()

    qt_internal_tl_git_fetch_shallow_ref_spec(
        REF_SPEC "${arg_REF_SPEC}"
        REMOTE "${remote}"
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        OUT_VAR_RESULT shallow_fetch_succeeded
        ${args}
    )

    # Attempt to unshallow a repo if a ref spec that we are meant to check out to,
    # is not known.
    if(shallow_fetch_succeeded)
        return()
    endif()

    message(DEBUG
        "Unshallowing repo in ${arg_WORKING_DIRECTORY} due to unknown "
        "refspec ${arg_REF_SPEC}")

    qt_internal_tl_git_unshallow_repo(
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        ${args}
    )
endfunction()

# Checks if given string looks like a sha1.
function(qt_internal_tl_is_sha1_ish value out_var)
    set(hex_digit "[0-9a-fA-F]")
    string(REPEAT "${hex_digit}" 5 hex_5)

    set(hex_digit_maybe "${hex_digit}?")
    string(REPEAT "${hex_digit_maybe}" 35 hex_35)

    # A sha1 would have at least 5 hex digits followed by 35 optional hex digits.
    set(sha1_regex "^${hex_5}${hex_35}$")

    if("${value}" MATCHES "${sha1_regex}")
        set(result TRUE)
    else()
        set(result FALSE)
    endif()

    set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# Directly updates the submodule sha in the supermodule, without having to checkout the submodule
# first.
# This is useful to be able to clone a specific revision with --depth 1 when using the "sync to
# module" feature.
# Causes the super module to have a "staged" change for the given submodule.
# Can only be used with a sha1, not a branch or tag or other refspec, because there might not be
# any repo info yet to resolve that refspec.
function(qt_internal_tl_modify_submodule_sha module revision working_directory)
    qt_internal_tl_handle_verbose_git_operations()

    # This mode means 'treat path as a git submodule'.
    set(mode "160000")

    execute_process(
        COMMAND git update-index --add --cacheinfo "${mode},${revision},${module}"
        RESULT_VARIABLE git_result
        WORKING_DIRECTORY "${working_directory}"
        ${swallow_output}
    )
    if(git_result)
        message(FATAL_ERROR "Failed to set initial submodule revision for '${module}'")
    endif()
endfunction()

# Unstages a previously staged change to the submodule sha in the supermodule.
# This should be run after qt_internal_tl_modify_submodule_sha and the submodule update operation,
# to not accidentally stage the change to the supermodule.
# It might still lieave the worktree dirty, because the checked out revision might be different
# from the one the supermodule expects, but that's fine, that's the point of the sync-to script.
function(qt_internal_tl_unstage_submodule_sha module working_directory)
    qt_internal_tl_handle_verbose_git_operations()

    execute_process(
        COMMAND git restore --staged "${module}"
        RESULT_VARIABLE git_result
        WORKING_DIRECTORY "${working_directory}"
        ${swallow_output}
    )
    if(git_result)
        message(FATAL_ERROR "Failed to unstage submodule revision change for '${module}'")
    endif()
endfunction()

# Transforms a refspec into a commit sha1.
# Useful for git commands that can't take a refspec.
function(qt_internal_tl_get_refspec_as_sha)
    set(opt_args
        FATAL
    )
    set(single_args
        REF_SPEC
        WORKING_DIRECTORY
        OUT_VAR
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    if(NOT arg_REF_SPEC)
        message(FATAL_ERROR "REF_SPEC is required")
    endif()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    if(NOT arg_OUT_VAR)
        message(FATAL_ERROR "OUT_VAR is required")
    endif()

    execute_process(
        COMMAND "git" "rev-parse" "${arg_REF_SPEC}"
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(git_result)
        message(WARNING "${git_stdout}")
        if(arg_FATAL)
            set(message_type FATAL_ERROR)
        else()
            set(message_type WARNING)
        endif()
        message("${message_type}"
            "Failed to get sha1 of ${arg_REF_SPEC} in '${arg_WORKING_DIRECTORY}': ${git_stderr}")
    endif()

    string(STRIP "${git_stdout}" git_stdout)
    set(${arg_OUT_VAR} "${git_stdout}" PARENT_SCOPE)
endfunction()

# Runs `submodule update --init` for a submodule.
#
# If REF_SPEC is passed and is a valid commit sha1, sets the current active submodule sha1 in the
# super module to the given sha1. This is useful for cloning a specific sha1 with --depth 1.
#
# GIT_DEPTH passes the given --depth for the submodule update operation.
#
# SHOW_PROGRESS passes --progress to the submodule update operation.
#
# OUT_VAR_RESULT - set to TRUE or FALSE depending on whether the submodule update init succeeded.

function(qt_internal_tl_run_submodule_update_init module)
    set(opt_args
        FAILURE_IS_WARNING
        SHOW_PROGRESS
    )
    set(single_args
        REF_SPEC
        GIT_DEPTH
        FAILURE_MESSAGE
        WORKING_DIRECTORY
        OUT_VAR_RESULT
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 1 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    qt_internal_tl_handle_verbose_git_operations()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    qt_internal_tl_is_sha1_ish("${arg_REF_SPEC}" is_sha1_revision)

    # We can only modify the submodule sha1 if we are given a sha1 reference, not any kind of
    # refspec.
    if(arg_REF_SPEC AND is_sha1_revision)
        qt_internal_tl_modify_submodule_sha("${module}" "${arg_REF_SPEC}"
            "${arg_WORKING_DIRECTORY}")
    endif()

    set(args "")
    set(extra_flags "$ENV{QT_TL_SUBMODULE_UPDATE_FLAGS}")
    if(extra_flags)
        list(APPEND args ${extra_flags})
    endif()
    if(arg_GIT_DEPTH)
        list(APPEND args --depth "${arg_GIT_DEPTH}")
    endif()
    if(arg_SHOW_PROGRESS)
        list(APPEND args --progress)
    endif()

    execute_process(
        COMMAND "git" "submodule" "update" "--init" ${args} "${module}"
        RESULT_VARIABLE git_result
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        ${swallow_output}
    )

    if(arg_REF_SPEC AND is_sha1_revision)
        qt_internal_tl_unstage_submodule_sha("${module}" "${arg_WORKING_DIRECTORY}")
    endif()

    if(git_result)
        set(result FALSE)

        if(arg_FAILURE_IS_WARNING)
            set(message_type WARNING)
        else()
            set(message_type FATAL_ERROR)
        endif()

        message(${message_type} "${arg_FAILURE_MESSAGE}")
    else()
        set(result TRUE)
    endif()

    if(arg_OUT_VAR_RESULT)
        set("${arg_OUT_VAR_RESULT}" "${result}" PARENT_SCOPE)
    endif()
endfunction()

# Clones a 'qt/${REPO_NAME}' repo from code.qt.io.
function(qt_internal_tl_git_clone_repo)
    set(opt_args
        SHOW_PROGRESS
    )
    set(single_args
        REPO_NAME
        GIT_DEPTH
        REMOTE_URL_BASE
        WORKING_DIRECTORY
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 0 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    qt_internal_tl_handle_verbose_git_operations()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    if(NOT arg_REPO_NAME)
        message(FATAL_ERROR "REPO_NAME is required")
    endif()

    if(arg_REMOTE_URL_BASE)
        set(remote_url_base "${arg_REMOTE_URL_BASE}")
    else()
        set(remote_url_base "https://code.qt.io/qt/")
    endif()

    set(remote_url "${remote_url_base}${arg_REPO_NAME}.git")

    message(NOTICE "Cloning '${arg_REPO_NAME}' from '${remote_url}'")

    set(clone_args "")
    if(arg_GIT_DEPTH)
        list(APPEND clone_args --depth "${arg_GIT_DEPTH}")
    endif()
    if(arg_SHOW_PROGRESS)
        list(APPEND clone_args --progress)
    endif()

    # Note that cloning does not allow fetching a specific sha1 directly if --depth is
    # specified. It can only take a branch or tag name. So we don't pass REF_SPEC here.
    execute_process(
        COMMAND "git" "clone" "${remote_url}" ${clone_args}
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        RESULT_VARIABLE git_result
        ${swallow_output}
    )
    if(git_result)
        message(FATAL_ERROR
            "Failed to clone '${module}' from '${remote_url}': ${git_output}")
    endif()
endfunction()

# Checks out a submodule to a given refspec, and runs 'git submodule update' in the submodule
# directory.
# If a regular checkout does not work, a detached checkout is attempted.
function(qt_internal_checkout module revision)
    set(opt_args
        SHOW_PROGRESS
    )
    set(single_args
        REMOTE_NAME
        WORKING_DIRECTORY
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 2 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    qt_internal_tl_handle_verbose_git_operations()

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "WORKING_DIRECTORY is required")
    endif()

    if(NOT arg_REMOTE_NAME)
        message(FATAL_ERROR "REMOTE_NAME is required")
    endif()

    set(shallow_args "")
    if(arg_SHOW_PROGRESS)
        list(APPEND shallow_args SHOW_PROGRESS)
    endif()

    qt_internal_tl_handle_shallow_repo(
        REF_SPEC "${revision}"
        REMOTE_NAME "${arg_REMOTE_NAME}"
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}/${module}"
        ${shallow_args}
    )

    message(NOTICE "Checking '${module}' out to revision '${revision}'")
    execute_process(
        COMMAND "git" "checkout" "${revision}"
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}/${module}"
        RESULT_VARIABLE git_result
        ${swallow_output}
    )
    if (git_result EQUAL 128)
        message(WARNING "${git_output}, trying detached checkout")
        execute_process(
            COMMAND "git" "checkout" "--detach" "${revision}"
            WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}/${module}"
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
    endif()
    if (git_result)
        message(FATAL_ERROR "Failed to check '${module}' out to '${revision}': ${git_output}")
    endif()

    set(args "")
    set(extra_flags "$ENV{QT_TL_SUBMODULE_UPDATE_FLAGS}")
    if(extra_flags)
        list(APPEND args ${extra_flags})
    endif()
    if(arg_SHOW_PROGRESS)
        list(APPEND args --progress)
    endif()

    execute_process(
        COMMAND "git" "submodule" "update" ${args}
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}/${module}"
        RESULT_VARIABLE git_result
        ${swallow_output}
    )
endfunction()

# Clones or creates a worktree, or initializes a submodule for $dependency, using the source of
# $dependent.
# Example dependent: qtdeclarative
# Example dependency: qtbase
function(qt_internal_get_dependency dependent dependency)
    set(opt_args
        SHOW_PROGRESS
    )
    set(single_args
        GIT_DEPTH
        REMOTE_NAME
        REF_SPEC
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 2 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    qt_internal_tl_handle_verbose_git_operations()

    if(NOT arg_REMOTE_NAME)
        message(FATAL_ERROR "REMOTE_NAME is required")
    endif()

    set(show_progress_args "")
    if(arg_SHOW_PROGRESS)
        set(show_progress_args SHOW_PROGRESS)
    endif()

    # This will hold the path to parent dir of the main ${dependent} worktree, regardless if it's a
    # clone or a git worktree.
    # So if dependent is 'src/qt6/qtshadertools'
    # gitdir will be     'src/qt6'
    # If dependent is      'worktrees/6.8-worktree/qtshadertools'
    # gitdir will still be 'src/qt6', not 'worktrees/6.8-worktree'
    set(gitdir "")

    # The remote url.
    set(remote "")

    # Worktree of dependent, aka who depends on dependency.
    set(dependent_path "${CMAKE_CURRENT_SOURCE_DIR}/${dependent}")

    # Try to get the dependent worktree git dir.
    execute_process(
        COMMAND "git" "rev-parse" "--absolute-git-dir"
        WORKING_DIRECTORY "${dependent_path}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(DEBUG "Original gitdir for '${dependent_path}' is '${git_stdout}'")

    string(FIND "${git_stdout}" "${module}" index)
    string(SUBSTRING "${git_stdout}" 0 ${index} gitdir)
    string(FIND "${gitdir}" ".git/modules" index)
    if(index GREATER -1) # submodules have not been absorbed
        string(SUBSTRING "${gitdir}" 0 ${index} gitdir)
    endif()

    message(DEBUG "Will check computed '${gitdir}' for worktrees and clones.")

    execute_process(
        COMMAND "git" "remote" "get-url" "${arg_REMOTE_NAME}"
        WORKING_DIRECTORY "${dependent_path}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(FIND "${git_stdout}" "${dependent}.git" index)
    string(SUBSTRING "${git_stdout}" 0 ${index} remote)

    message(DEBUG "Original remote for '${dependent_path}' is '${git_stdout}'")

    set(maybe_super_module_path "${gitdir}")
    set(maybe_submodule_path "${maybe_super_module_path}${dependency}")
    set(maybe_submodule_git_path "${maybe_submodule_path}/.git")

    set(maybe_existing_worktree_path "${maybe_submodule_path}")

    if(EXISTS "${maybe_super_module_path}.gitmodules" AND NOT EXISTS "${maybe_submodule_git_path}")
        set(use_submodule_init TRUE)
        message(DEBUG
            "Will attempt to initialize submodule using supermodule ${maybe_super_module_path}")
    else()
        set(use_submodule_init FALSE)
        if(EXISTS "${maybe_existing_worktree_path}")
            message(DEBUG "Will attempt to use worktree from ${maybe_existing_worktree_path}")
        else()
            message(DEBUG "Will clone from ${remote}")
        endif()
    endif()

    if(use_submodule_init)
        # super repo exists, but the submodule we need does not - try to initialize
        message(NOTICE "Initializing submodule '${dependency}' from ${maybe_super_module_path}")

        set(args
            FAILURE_MESSAGE
                "Failed to initialize submodule '${dependency}' from ${maybe_super_module_path}"

            # Ignore errors, fall back to an independent clone below.
            FAILURE_IS_WARNING

            OUT_VAR_RESULT submodule_update_init_result
            WORKING_DIRECTORY "${gitdir}"
            ${show_progress_args}
        )
        if(arg_GIT_DEPTH)
            list(APPEND args
                GIT_DEPTH "${arg_GIT_DEPTH}"
                REF_SPEC "${arg_REF_SPEC}"
        )
        endif()
        qt_internal_tl_run_submodule_update_init("${dependency}" ${args})
    endif()

    # If the submodule was initialized in the super repo in the code above, and the location where
    # we're supposed to clone the dependency is the same, skip trying to clone the dependency or
    # setting up a worktree, because it's already there.
    set(new_dependency_path "${CMAKE_CURRENT_SOURCE_DIR}/${dependency}")
    if(EXISTS "${new_dependency_path}" AND
            "${new_dependency_path}" STREQUAL "${maybe_existing_worktree_path}")
        return()
    endif()

    if(EXISTS "${maybe_existing_worktree_path}")
        # for the module we want, there seems to be a clone parallel to what we have
        message(NOTICE "Adding worktree for ${dependency} from ${gitdir}${dependency}")
        execute_process(
            COMMAND "git" "worktree" "add" "--detach" "${new_dependency_path}"
            WORKING_DIRECTORY "${maybe_existing_worktree_path}"
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
        if(git_result)
            message(FATAL_ERROR
                "Failed to add worktree '${module}' from '${new_dependency_path}': ${git_output}")
        endif()
    else()
        # We didn't find an existing clone or worktree, so clone from the same remote.
        set(clone_args "")
        if(arg_GIT_DEPTH)
            list(APPEND clone_args GIT_DEPTH "${arg_GIT_DEPTH}")
        endif()
        if(arg_SHOW_PROGRESS)
            list(APPEND clone_args SHOW_PROGRESS)
        endif()

        qt_internal_tl_git_clone_repo(
            REPO_NAME "${dependency}"
            REMOTE_URL_BASE "${remote}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            ${clone_args}
        )
    endif()
endfunction()

# Syncs a submodule to a given refspec, collects its dependencies, and then checks out
# the submodule and its dependencies to a consistent set, according to the submodule
# dependencies.yaml file.
#
# A special case is when the module is ".", in which case all submodules are checked out to the
# given refspec, e.g. check out everything to origin/dev/HEAD.
#
# Initializes the submodule and any of its dependencies if they are not already initialized, when
# executed in a qt5.git checkout.
#
# Clones the specified submodule from code.qt.io if it missing, and not in a qt5.git checkout.
function(qt_internal_sync_to module)
    set(opt_args
        VERBOSE
        SHOW_PROGRESS
    )
    set(single_args
        SYNC_REF
        REMOTE_NAME
        GIT_DEPTH
    )
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 1 arg "${opt_args}" "${single_args}" "${multi_args}")
    qt_internal_tl_validate_all_args_are_parsed(arg)

    if(arg_VERBOSE)
        # This is meant to trickle into scopes of other functions as well.
        set(VERBOSE TRUE)
    endif()

    set(show_progress_args "")
    if(arg_SHOW_PROGRESS)
        set(show_progress_args SHOW_PROGRESS)
    endif()

    if(arg_REMOTE_NAME)
        set(remote_name "${arg_REMOTE_NAME}")
    else()
        set(remote_name "origin")
    endif()

    set(revision "${arg_SYNC_REF}")

    # Special casing "." as the target module - checkout all initialized submodules to $revision.
    # If revision is unset, check out to dev.
    if("${module}" STREQUAL ".")
        if(NOT revision)
            set(revision "dev")
        endif()

        qt_internal_find_modules(modules)
        foreach(module IN LISTS modules)
            qt_internal_checkout("${module}" "${revision}" ${show_progress_args}
                REMOTE_NAME "${remote_name}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )
        endforeach()
        return()
    endif()

    # If no revision given, checkout to the HEAD as specified by the super module.
    if(NOT revision)
        set(revision "HEAD")
    endif()

    set(submodule_path "${CMAKE_CURRENT_SOURCE_DIR}/${module}")
    set(submodule_git_path "${submodule_path}/.git")

    # We are in a qt5.git dir, but the requested submodule is not initialized yet, try to
    # initialize it.
    qt_internal_tl_is_super_repo(is_super_repo)
    if(is_super_repo AND NOT EXISTS "${submodule_git_path}")
        message(NOTICE "Initializing submodule '${module}' within supermodule.")

        set(args
            FAILURE_MESSAGE "Failed to initialize initial submodule '${module}'"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            ${show_progress_args}
        )
        if(arg_GIT_DEPTH)
            list(APPEND args
                GIT_DEPTH "${arg_GIT_DEPTH}"
                REF_SPEC "${revision}"
            )
        endif()
        qt_internal_tl_run_submodule_update_init("${module}" ${args})
    endif()

    # If we were in a qt5.git dir, the submodule should have been initialized by now.
    # If we were in some random src/ dir, we need to manually clone the repo.
    if(NOT EXISTS "${submodule_path}")
        qt_internal_tl_git_clone_repo(
            REPO_NAME "${module}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            ${show_progress_args}
        )
    endif()

    if(NOT EXISTS "${submodule_git_path}")
        message(FATAL_ERROR "No worktree for '${module}' found in '${submodule_path}'")
    endif()

    # Check out the submodule to the given refspec.
    qt_internal_checkout("${module}" "${revision}" ${show_progress_args}
        REMOTE_NAME "${remote_name}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )

    qt_internal_resolve_module_dependencies(${module} initial_dependencies initial_revisions)
    if(initial_dependencies)
        foreach(dependency ${initial_dependencies})
            if(dependency MATCHES "^tqtc-")
                message(WARNING
                    "Handling of tqtc- repos will likely fail. Fixing this is non-trivial.")
                break()
            endif()
        endforeach()
    endif()

    set(revision "")
    set(should_visit_dependencies "1")
    # Load all dependencies for $module, then iterate over the dependencies in reverse order,
    # and check out the first that isn't already at the required revision.
    # Repeat everything (we need to reload dependencies after each checkout) until no more checkouts
    # are done.
    while(${should_visit_dependencies})
        qt_internal_resolve_module_dependencies(${module} dependencies revisions)
        message(DEBUG "${module} dependencies: ${dependencies}")
        message(DEBUG "${module} revisions   : ${revisions}")

        list(LENGTH dependencies count)
        if (count EQUAL "0")
            message(NOTICE "Module ${module} has no dependencies")
            return()
        endif()

        math(EXPR count "${count} - 1")
        set(should_visit_dependencies 0)
        foreach(i RANGE ${count} 0 -1 )
            list(GET dependencies ${i} dependency)
            list(GET revisions ${i} revision)
            if ("${revision}" STREQUAL "HEAD")
                message(DEBUG "Not changing checked out revision of ${dependency}")
                continue()
            endif()

            # When in a super module, the dependency directory might exist, but is empty if the
            # submodule was not yet initiallized. Check its existence and initialization state
            # by looking at the existence of the .git file or directory.
            if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dependency}/.git")
                message(DEBUG
                    "No worktree for '${dependency}' found in '${CMAKE_CURRENT_SOURCE_DIR}'. "
                    "Trying to acquire it."
                )

                set(args ${show_progress_args})
                if(arg_GIT_DEPTH)
                    list(APPEND args GIT_DEPTH "${arg_GIT_DEPTH}")
                endif()
                qt_internal_get_dependency("${module}" "${dependency}"
                    REF_SPEC "${revision}"
                    REMOTE_NAME "${remote_name}"
                    ${args}
                )

                set(should_visit_dependencies 1)
            endif()

            qt_internal_tl_get_refspec_as_sha(
                REF_SPEC "HEAD"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${dependency}"
                OUT_VAR head_ref
            )

            if("${head_ref}" STREQUAL "${revision}")
                message(DEBUG
                    "The dependency ${dependency} is already checked out to ${revision}. "
                    "Continuing to next dependency."
                )
                continue()
            endif()

            qt_internal_checkout("${dependency}" "${revision}" ${show_progress_args}
                REMOTE_NAME "${remote_name}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )
            set(should_visit_dependencies 1)

            # Start revisiting the dependencies in the while loop.
            break()
        endforeach()
    endwhile()
    message(DEBUG "Module syncing finished.")
endfunction()

# Runs user specified command for all qt repositories in qt directory.
# Similar to git submodule foreach, except without relying on .gitmodules existing.
# Useful for worktree checkouts.
function(qt_internal_foreach_repo_run)
    cmake_parse_arguments(PARSE_ARGV 0 arg
                          ""
                          ""
                          "ARGS"
    )
    if(NOT arg_ARGS)
        message(FATAL_ERROR "No arguments specified to qt_internal_foreach_repo_run")
    endif()
    separate_arguments(args NATIVE_COMMAND "${arg_ARGS}")

    # Find the qt repos
    qt_internal_find_modules(modules)

    # Hack to support color output on unix systems
    # https://stackoverflow.com/questions/18968979/how-to-make-colorized-message-with-cmake
    execute_process(COMMAND
        /usr/bin/tty
        OUTPUT_VARIABLE tty_name
        RESULT_VARIABLE tty_exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    set(color_supported FALSE)
    set(output_goes_where "")
    if(NOT tty_exit_CODE AND tty_name)
        set(color_supported TRUE)
        set(output_goes_where "OUTPUT_FILE" "${tty_name}")
    endif()

    # Count successes and failures.
    set(count_success "0")
    set(count_failure "0")

    # Show colored error markers.
    set(color "--normal")
    if(color_supported)
        set(color "--red")
    endif()

    set(failing_modules "")
    foreach(module IN LISTS modules)
        message("Entering '${module}'")
        execute_process(
            COMMAND ${args}
            WORKING_DIRECTORY "${module}"
            ${output_goes_where}
            RESULT_VARIABLE cmd_result
        )
        if(cmd_result)
            math(EXPR count_failure "${count_failure}+1")
            # cmake_echo_color is undocumented, but lets us output colors and control newlines.
            execute_process(
                COMMAND
                ${CMAKE_COMMAND} -E env CLICOLOR_FORCE=1
                ${CMAKE_COMMAND} -E cmake_echo_color "${color}"
                "Process execution failed here ^^^^^^^^^^^^^^^^^^^^"
            )
            list(APPEND failing_modules "${module}")
        else()
            math(EXPR count_success "${count_success}+1")
        endif()
    endforeach()

    # Show summary with colors.
    set(color "--normal")
    if(count_failure AND color_supported)
        set(color "--red")
    endif()

    message("\nSummary\n=======\n")
    execute_process(
        COMMAND
            ${CMAKE_COMMAND} -E cmake_echo_color --normal --no-newline "Failures: "
    )
    execute_process(
        COMMAND
            ${CMAKE_COMMAND} -E env CLICOLOR_FORCE=1
            ${CMAKE_COMMAND} -E cmake_echo_color "${color}" "${count_failure}"
    )
    if(failing_modules)
        list(JOIN failing_modules ", " failing_modules)
        execute_process(
            COMMAND
                ${CMAKE_COMMAND} -E cmake_echo_color --normal
                    "Failing submodules: ${failing_modules}"
        )
    endif()

    message("Successes: ${count_success}")
endfunction()

# The function collects repos and dependencies that are required to build
# repos listed in ARGN. If the BUILD_<repo> is defined the 'repo' will be
# excluded from the list.
function(qt_internal_collect_modules_only out_repos)
    set(initial_modules "${ARGN}")
    get_filename_component(qt5_repo_dir "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

    # Overriding CMAKE_CURRENT_SOURCE_DIR is ugly but works
    set(CMAKE_CURRENT_SOURCE_DIR "${qt5_repo_dir}")
    if(NOT initial_modules)
        qt_internal_find_modules(initial_modules)
    endif()

    qt_internal_sort_module_dependencies("${initial_modules}" ${out_repos})
    foreach(module IN LISTS ${out_repos})
        # Check for unmet dependencies
        if(DEFINED BUILD_${module} AND NOT BUILD_${module})
            list(REMOVE_ITEM ${out_repos} ${module})
            continue()
        endif()
        get_property(required_deps GLOBAL PROPERTY QT_REQUIRED_DEPS_FOR_${module})
        get_property(dependencies GLOBAL PROPERTY QT_DEPS_FOR_${module})
        foreach(dep IN LISTS dependencies)
            set(required FALSE)
            if(dep IN_LIST required_deps)
                set(required TRUE)
            endif()
            if(required AND DEFINED BUILD_${dep} AND NOT BUILD_${dep})
                set(BUILD_${module} FALSE)
                list(REMOVE_ITEM ${out_repos} ${module})
                break()
            endif()
        endforeach()
    endforeach()

    set(${out_repos} "${${out_repos}}" PARENT_SCOPE)
endfunction()
