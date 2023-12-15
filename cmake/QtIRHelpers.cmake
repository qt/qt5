# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# Includes all helper files for access to necessary functions.
macro(qt_ir_include_all_helpers)
    include(QtIRCommandLineHelpers)
    include(QtIRGitHelpers)
    include(QtIROptionsHelpers)
    include(QtIRParsingHelpers)
    include(QtIRProcessHelpers)
    include(QtTopLevelHelpers)
endmacro()

# Convenience macro to get the working directory from the arguments passed to
# cmake_parse_arguments. Saves a few lines and makes reading the code slightly
# easier.
macro(qt_ir_get_working_directory_from_arg out_var)
    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "No working directory specified")
    endif()
    set(${out_var} "${arg_WORKING_DIRECTORY}")
endmacro()

# Convenience function to set the variable to the name of cmake_parse_arguments
# flag option if it is active.
function(qt_ir_get_cmake_flag flag_name out_var)
    if(arg_${flag_name})
        set(${out_var} "${flag_name}" PARENT_SCOPE)
    else()
        set(${out_var} "" PARENT_SCOPE)
    endif()
endfunction()

# Checks whether any of the arguments passed on the command line are options
# that are marked as unsupported in the cmake port of init-repository.
function(qt_ir_check_if_unsupported_options_used out_var out_var_option_name)
    qt_ir_get_unsupported_options(unsupported_options)

    set(unsupported_options_used FALSE)
    foreach(unsupported_option IN LISTS unsupported_options)
        qt_ir_get_option_value(${unsupported_option} value)
        if(value)
            set(${out_var_option_name} "${unsupported_option}" PARENT_SCOPE)
            set(unsupported_options_used TRUE)
            break()
        endif()
    endforeach()
    set(${out_var} "${unsupported_options_used}" PARENT_SCOPE)
endfunction()

# When an unsupported option is used, show an error message and tell the user
# to run the perly script manually.
function(qt_ir_show_error_how_to_run_perl opt_file unsupported_option_name)
    qt_ir_get_raw_args_from_optfile("${opt_file}" args)
    string(REPLACE ";" " " args "${args}")

    set(perl_cmd "perl ./init-repository.pl ${args}")

    message(FATAL_ERROR
        "Option '${unsupported_option_name}' is not implemented in the cmake "
        "port of init-repository. Please let us know if this option is really "
        "important for you at https://bugreports.qt.io/. Meanwhile, you can "
        "still run the perl script directly. \n ${perl_cmd}")
endfunction()

# Check whether help was requested.
function(qt_ir_is_help_requested out_var)
    qt_ir_get_option_value(help value)
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Check whether the verbose option was used.
function(qt_ir_is_verbose out_var)
    qt_ir_get_option_value(verbose value)
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Main logic of the script.
function(qt_ir_run_after_args_parsed)
    qt_ir_is_help_requested(show_help)
    if(show_help)
        qt_ir_show_help()
        return()
    endif()

    set(working_directory "${CMAKE_CURRENT_SOURCE_DIR}")

    qt_ir_handle_if_already_initialized(should_exit "${working_directory}")
    if(should_exit)
        return()
    endif()

    # This will be used by the module subset processing to determine whether we
    # should re-initialize the previously initialized (existing) subset.
    qt_ir_check_if_already_initialized_cmake_style(is_initialized
        "${working_directory}" FORCE_QUIET)
    set(previously_initialized_option "")
    if(is_initialized)
        set(previously_initialized_option PREVIOUSLY_INITIALIZED)
    endif()


    # Ge the name of the qt5 repo (tqtc- or not) and the base url for all other repos
    qt_ir_get_qt5_repo_name_and_base_url(
        OUT_VAR_QT5_REPO_NAME qt5_repo_name
        OUT_VAR_BASE_URL base_url
        WORKING_DIRECTORY "${working_directory}")

    qt_ir_get_already_initialized_submodules("${prefix}"
        already_initialized_submodules
        "${qt5_repo_name}"
        "${working_directory}")

    # Get some additional options to pass down.
    qt_ir_get_option_value(alternates alternates)
    qt_ir_get_option_as_cmake_flag_option(branch "CHECKOUT_BRANCH" checkout_branch_option)

    # The prefix for the cmake-style 'dictionary' that will be used by various functions.
    set(prefix "ir_top")

    # Initialize and clone the submodules
    qt_ir_handle_init_submodules("${prefix}"
        ALTERNATES "${alternates}"
        ALREADY_INITIALIZED_SUBMODULES "${already_initialized_submodules}"
        BASE_URL "${base_url}"
        PARENT_REPO_BASE_GIT_PATH "${qt5_repo_name}"
        PROCESS_SUBMODULES_FROM_COMMAND_LINE
        WORKING_DIRECTORY "${working_directory}"
        ${checkout_branch_option}
        ${previously_initialized_option}
    )

    # Add gerrit remotes.
    qt_ir_add_git_remotes("${qt5_repo_name}" "${working_directory}")

    # Install commit and other various hooks.
    qt_ir_install_git_hooks(
        PARENT_REPO_BASE_GIT_PATH "${qt5_repo_name}"
        WORKING_DIRECTORY "${working_directory}"
    )

    # Mark the repo as being initialized.
    qt_ir_set_is_initialized("${working_directory}")
endfunction()

# Entrypoint of the init-repository script.
function(qt_ir_run_main_script)
    qt_ir_set_known_command_line_options()
    qt_ir_process_args_from_optfile("${OPTFILE}")

    qt_ir_check_if_unsupported_options_used(
        unsupported_options_used option_name)
    if(unsupported_options_used)
        qt_ir_show_error_how_to_run_perl("${OPTFILE}" "${option_name}")
    endif()

    qt_ir_run_after_args_parsed()
endfunction()
