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

# There are some init-repository options that we do not want to allow when called from
# configure. Make sure we error out when they are set by the user.
function(qt_ir_validate_options_for_configure)
    set(disallowed_options
        # Disallow mirror options, because users should set up a proper git mirror manually,
        # not via configure.
        mirror
        oslo
        berlin
    )
    foreach(disallowed_option IN LISTS disallowed_options)
        qt_ir_get_option_value(${disallowed_option} value)
        if(value)
            set(msg
                "Initialization option '${disallowed_option}' is not supported by configure. "
                "If you think this option should be supported, please let us know at "
                "https://bugreports.qt.io/"
            )
            message(FATAL_ERROR ${msg})
        endif()
    endforeach()
endfunction()

# Handle the case when init-repository is called from the configure script.
function(qt_ir_handle_called_from_configure top_level_src_path out_var_exit_reason)
    # Nothing special to do if we're not called from configure.
    qt_ir_is_called_from_configure(is_called_from_configure)
    if(NOT is_called_from_configure)
        set(${out_var_exit_reason} FALSE PARENT_SCOPE)
        return()
    endif()

    # Check whether qtbase was cloned, if not, tell the user how to initialize
    # the repos as part of the configure script.
    qt_ir_get_option_value(init-submodules init_submodules)
    set(configure_script "${top_level_src_path}/qtbase/configure")
    if(NOT EXISTS "${configure_script}" AND NOT init_submodules)
        set(msg "Oops. It looks like you didn't initialize any submodules yet.\nCall configure "
            "with the -init-submodules option to automatically clone a default set of "
            "submodules before configuring Qt.\nYou can also pass "
            "-submodules submodule2,submodule3 to clone a particular set of submodules "
            "and their dependencies. See ./init-repository --help for more information on values "
            "accepted by --module-subset (which gets its values from -submodules).")
        message(${msg})
        set(${out_var_exit_reason} NEED_INIT_SUBMODULES PARENT_SCOPE)
        return()
    endif()

    # Don't do init-repository things when called from configure, qtbase exists and the
    # -init-submodules option is not passed. We assume the repo was already
    # initialized.
    if(NOT init_submodules)
        set(${out_var_exit_reason} ALREADY_INITIALIZED PARENT_SCOPE)
        return()
    endif()

    qt_ir_validate_options_for_configure()

    # -init_submodules implies --force
    qt_ir_set_option_value(force TRUE)

    set(${out_var_exit_reason} FALSE PARENT_SCOPE)
endfunction()

# Returns a list of command line arguments with the init-repository specific
# options removed, which are not recognized by configure.
# It also handles -submodules values like 'essential', 'existing' and '-qtsvg' and transforms them
# into the final list of submodules to be included and excluded, which are then translated
# to configure -submodules and -skip options.
function(qt_ir_get_args_from_optfile_configure_filtered optfile_path out_var)
    cmake_parse_arguments(arg "ALREADY_INITIALIZED" "" "" ${ARGV})

    # Get args unknown to init-repository, and pass them to configure as-is.
    qt_ir_get_unknown_args(unknown_args)

    set(filtered_args ${unknown_args})
    set(extra_configure_args "")
    set(extra_cmake_args "")

    # If the -submodules or --module-subset options were specified, transform
    # the values into something configure understands and pass them to configure.
    qt_ir_get_option_value(module-subset submodules)
    if(submodules)
        qt_ir_get_top_level_submodules(include_submodules exclude_submodules)
        if(NOT include_submodules AND arg_ALREADY_INITIALIZED)
            string(REPLACE "," ";" include_submodules "${submodules}")
        endif()

        # qtrepotools is always implicitly cloned, but it doesn't actually
        # have a CMakeLists.txt, so remove it.
        list(REMOVE_ITEM include_submodules "qtrepotools")

        # Make sure to explicitly pass -DBUILD_<module>=ON, in case they were
        # skipped before, otherwise configure might fail.
        if(include_submodules)
            set(explicit_build_submodules "${include_submodules}")
            list(TRANSFORM explicit_build_submodules PREPEND "-DBUILD_")
            list(TRANSFORM explicit_build_submodules APPEND "=ON")
            list(APPEND extra_cmake_args ${explicit_build_submodules})
        endif()

        list(JOIN include_submodules "," include_submodules)
        list(JOIN exclude_submodules "," exclude_submodules)

        # Handle case when the -skip argument is already passed.
        # In that case read the passed values, merge with new ones,
        # remove both the -skip and its values, and re-add it later.
        list(FIND filtered_args "-skip" skip_index)
        if(exclude_submodules AND skip_index GREATER -1)
            list(LENGTH filtered_args filtered_args_length)
            math(EXPR skip_args_index "${skip_index} + 1")

            if(skip_args_index LESS filtered_args_length)
                list(GET filtered_args "${skip_args_index}" skip_args)
                string(REPLACE "," ";" skip_args "${skip_args}")
                list(APPEND skip_args ${exclude_submodules})
                list(REMOVE_DUPLICATES skip_args)
                list(JOIN skip_args "," exclude_submodules)
                list(REMOVE_AT filtered_args "${skip_args_index}")
                list(REMOVE_AT filtered_args "${skip_index}")
            endif()
        endif()

        # Handle case when only '-submodules existing' is passed and the
        # subset ends up empty.
        if(include_submodules)
            list(APPEND extra_configure_args "-submodules" "${include_submodules}")
        endif()
        if(exclude_submodules)
            list(APPEND extra_configure_args "-skip" "${exclude_submodules}")
        endif()
    endif()

    # Insert the extra arguments into the proper positions before and after '--'.
    list(FIND filtered_args "--" cmake_args_index)

    # -- is not found
    if(cmake_args_index EQUAL -1)
        # Append extra configure args if present
        if(extra_configure_args)
            list(APPEND filtered_args ${extra_configure_args})
        endif()
        # Append extra cmake args if present, but make sure to add -- first at the end
        if(extra_cmake_args)
            list(APPEND filtered_args "--")
            list(APPEND filtered_args ${extra_cmake_args})
        endif()
    else()
        # -- is found, that means we probably have cmake args
        # Insert extra configure args if present, before the -- index.
        if(extra_configure_args)
            list(INSERT filtered_args "${cmake_args_index}" ${extra_configure_args})
        endif()
        # Find the -- index again, because it might have moved
        list(FIND filtered_args "--" cmake_args_index)
        # Compute the index of the argument after the --.
        math(EXPR cmake_args_index "${cmake_args_index} + 1")
        # Insert extra cmake args if present, after the -- index.
        if(extra_cmake_args)
            list(INSERT filtered_args "${cmake_args_index}" ${extra_cmake_args})
        endif()
    endif()

    # Pass --help if it was requested.
    qt_ir_is_help_requested(show_help)
    if(show_help)
        list(APPEND filtered_args "-help")
    endif()

    set(${out_var} "${filtered_args}" PARENT_SCOPE)
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
    qt_ir_prettify_command_args(args "${args}")

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

function(qt_ir_is_called_from_configure out_var)
    qt_ir_get_option_value(from-configure value)
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Main logic of the script.
function(qt_ir_run_after_args_parsed top_level_src_path out_var_exit_reason)
    set(${out_var_exit_reason} FALSE PARENT_SCOPE)

    qt_ir_is_called_from_configure(is_called_from_configure)

    qt_ir_is_help_requested(show_help)
    if(show_help AND NOT is_called_from_configure)
        qt_ir_show_help()
        set(${out_var_exit_reason} SHOWED_HELP PARENT_SCOPE)
        return()
    endif()

    set(working_directory "${top_level_src_path}")

    qt_ir_handle_if_already_initialized(already_initialized "${working_directory}")
    if(already_initialized)
        set(${out_var_exit_reason} ALREADY_INITIALIZED PARENT_SCOPE)
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
    qt_ir_get_option_as_existing_absolute_path(alternates alternates)
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
        TOP_LEVEL_SRC_PATH "${top_level_src_path}"
        WORKING_DIRECTORY "${working_directory}"
    )

    # Mark the repo as being initialized.
    qt_ir_set_is_initialized("${working_directory}")
endfunction()

# Entrypoint of the init-repository script.
function(qt_ir_run_main_script top_level_src_path out_var_exit_reason)
    set(${out_var_exit_reason} FALSE PARENT_SCOPE)

    # Windows passes backslash paths.
    file(TO_CMAKE_PATH "${top_level_src_path}" top_level_src_path)

    qt_ir_set_known_command_line_options()

    # If called from configure, there might be arguments that init-repository doesn't know about
    # because they are meant for configure. In that case ignore unknown arguments.
    qt_ir_get_option_value(from-configure from_configure)
    if(from_configure)
        set(ignore_unknown_args "IGNORE_UNKNOWN_ARGS")
    else()
        set(ignore_unknown_args "")
    endif()

    qt_ir_process_args_from_optfile("${OPTFILE}" "${ignore_unknown_args}")

    qt_ir_handle_called_from_configure("${top_level_src_path}" exit_reason)
    if(exit_reason)
        set(${out_var_exit_reason} "${exit_reason}" PARENT_SCOPE)
        return()
    endif()

    qt_ir_check_if_unsupported_options_used(
        unsupported_options_used option_name)
    if(unsupported_options_used)
        qt_ir_show_error_how_to_run_perl("${OPTFILE}" "${option_name}")
    endif()

    qt_ir_run_after_args_parsed("${top_level_src_path}" exit_reason)
    set(${out_var_exit_reason} "${exit_reason}" PARENT_SCOPE)

    # TODO: Consider using cmake_language(EXIT <exit-code>) when cmake 3.29 is released.
endfunction()
