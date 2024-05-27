# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# This file contains a modified subset of the qtbase/QtProcessConfigureArgs.cmake commands
# with renamed functions, because we need similar logic for init-repository, but
# we can't access qtbase before we clone it.

# Call a function with the given arguments.
function(qt_ir_call_function func)
    set(call_code "${func}(")
    math(EXPR n "${ARGC} - 1")
    foreach(i RANGE 1 ${n})
        string(APPEND call_code "\"${ARGV${i}}\" ")
    endforeach()
    string(APPEND call_code ")")
    string(REPLACE "\\" "\\\\" call_code "${call_code}")
    if(${CMAKE_VERSION} VERSION_LESS "3.18.0")
        set(incfile qt_tmp_func_call.cmake)
        file(WRITE "${incfile}" "${call_code}")
        include(${incfile})
        file(REMOVE "${incfile}")
    else()
        cmake_language(EVAL CODE "${call_code}")
    endif()
endfunction()

# Show an error.
function(qt_ir_add_error)
    message(FATAL_ERROR ${ARGV})
endfunction()

# Check if there are still unhandled command line arguments.
function(qt_ir_args_has_next_command_line_arg out_var)
    qt_ir_get_unhandled_args(args)

    list(LENGTH args n)
    if(n GREATER 0)
        set(result TRUE)
    else()
        set(result FALSE)
    endif()
    set(${out_var} ${result} PARENT_SCOPE)
endfunction()

# Get the next unhandled command line argument without popping it.
function(qt_ir_args_peek_next_command_line_arg out_var)
    qt_ir_get_unhandled_args(args)
    list(GET args 0 result)
    set(${out_var} ${result} PARENT_SCOPE)
endfunction()

# Get the next unhandled command line argument.
function(qt_ir_args_get_next_command_line_arg out_var)
    qt_ir_get_unhandled_args(args)
    list(POP_FRONT args result)
    qt_ir_set_unhandled_args("${args}")
    set(${out_var} ${result} PARENT_SCOPE)
endfunction()

# Helper macro to parse the arguments for the command line options.
macro(qt_ir_commandline_option_parse_arguments)
    set(options UNSUPPORTED COMMON)
    set(oneValueArgs TYPE NAME SHORT_NAME ALIAS VALUE DEFAULT_VALUE)
    set(multiValueArgs VALUES MAPPING)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
endmacro()

# We use this to define the command line options that init-repository accepts.
# Arguments
#  name - name of the long form option
#    e.g. 'module-subset' will parse '--module-subset'
#  UNSUPPORTED - mark the option as unsupported in the cmake port of init-repository,
#    which means we will fall back to calling the perl script instead
#  TYPE - the type of the option, currently we support boolean, string and void
#  VALUE - the value to be set for a 'void' type option
#  VALUES - the valid values for an option
#  MAPPING - currently unused
#  SHORT_NAME - an alternative short name flag,
#    e.g. 'f' will parse -f for --force
#  ALIAS - mark the option as an alias of another option, both will have the
#    same value when retrieved.
#  DEFAULT_VALUE - the default value to be set for the option when it's not specified
#    on the command line
#  COMMON - the argument is common for init-repository and configure scripts
#
# NOTE: Make sure to update the SHORT_NAME code path when adding new options.
function(qt_ir_commandline_option_helper name)
    qt_ir_commandline_option_parse_arguments(${ARGN})

    set(unsupported_options "${commandline_known_unsupported_options}")
    if(arg_UNSUPPORTED)
        set(commandline_option_${name}_unsupported
            "${arg_UNSUPPORTED}" PARENT_SCOPE)
        list(APPEND unsupported_options "${name}")
    endif()
    set(commandline_known_unsupported_options "${unsupported_options}" PARENT_SCOPE)

    set(commandline_known_options
        "${commandline_known_options};${name}" PARENT_SCOPE)

    if(arg_COMMON)
        set(commandline_option_${name}_common "true" PARENT_SCOPE)
        if(NOT "${arg_TYPE}" STREQUAL "boolean")
            message(FATAL_ERROR "${name} is '${arg_TYPE}', but COMMON arguments can be"
                " 'boolean' only.")
        endif()
    endif()

    set(commandline_option_${name}_type "${arg_TYPE}" PARENT_SCOPE)

    if(NOT "${arg_VALUE}" STREQUAL "")
        set(commandline_option_${name}_value "${arg_VALUE}" PARENT_SCOPE)
    endif()

    if(arg_VALUES)
        set(commandline_option_${name}_values ${arg_VALUES} PARENT_SCOPE)
    elseif(arg_MAPPING)
        set(commandline_option_${name}_mapping ${arg_MAPPING} PARENT_SCOPE)
    endif()

    if(NOT "${arg_SHORT_NAME}" STREQUAL "")
        set(commandline_option_${name}_short_name "${arg_SHORT_NAME}" PARENT_SCOPE)
    endif()

    if(NOT "${arg_ALIAS}" STREQUAL "")
        set(commandline_option_${name}_alias "${arg_ALIAS}" PARENT_SCOPE)
    endif()

    # Should be last, in case alias was specified
    if(NOT "${arg_DEFAULT_VALUE}" STREQUAL "")
        set(commandline_option_${name}_default_value "${arg_DEFAULT_VALUE}" PARENT_SCOPE)
        qt_ir_command_line_set_input("${name}" "${arg_DEFAULT_VALUE}")
    endif()
endfunction()

# Defines an option that init-repository understands.
# Uses qt_ir_commandline_option_helper to define both long and short option names.
macro(qt_ir_commandline_option name)
    # Define the main option
    qt_ir_commandline_option_helper("${name}" ${ARGN})

    qt_ir_commandline_option_parse_arguments(${ARGN})

    # Define the short name option if it's requested
    if(NOT "${arg_SHORT_NAME}" STREQUAL ""
        AND "${commandline_option_${arg_SHORT_NAME}_type}" STREQUAL "")
        set(unsupported "")
        if(arg_UNSUPPORTED)
            set(unsupported "UNSUPPORTED")
        endif()

        set(common "")
        if(arg_COMMON)
            set(common "COMMON")
        endif()

        qt_ir_commandline_option_helper("${arg_SHORT_NAME}"
            TYPE "${arg_TYPE}"
            ALIAS "${name}"
            VALUE "${arg_VALUE}"
            VALUES ${arg_VALUES}
            MAPPING ${arg_MAPPING}
            DEFAULT_VALUE ${arg_DEFAULT_VALUE}
            ${unsupported}
            ${common}
        )
    endif()
endmacro()

# Saves the value of a command line option into a global property.
function(qt_ir_command_line_set_input name val)
    if(NOT "${commandline_option_${name}_alias}" STREQUAL "")
        set(name "${commandline_option_${name}_alias}")
    endif()

    set_property(GLOBAL PROPERTY _qt_ir_input_${name} "${val}")
    set_property(GLOBAL APPEND PROPERTY _qt_ir_inputs ${name})
endfunction()

# Appends a value of a command line option into a global property.
# Currently unused
function(qt_ir_command_line_append_input name val)
    if(NOT "${commandline_option_${name}_alias}" STREQUAL "")
        set(name "${commandline_option_${name}_alias}")
    endif()

    get_property(oldval GLOBAL PROPERTY _qt_ir_input_${name})
    if(NOT "${oldval}" STREQUAL "")
        string(PREPEND val "${oldval};")
    endif()
    qt_ir_command_line_set_input(${name} "${val}" )
endfunction()

# Checks if the value of a command line option is valid.
function(qt_ir_validate_value opt val out_var)
    set(${out_var} TRUE PARENT_SCOPE)

    set(valid_values ${commandline_option_${arg}_values})
    list(LENGTH valid_values n)
    if(n EQUAL 0)
        return()
    endif()

    foreach(v ${valid_values})
        if(val STREQUAL v)
            return()
        endif()
    endforeach()

    set(${out_var} FALSE PARENT_SCOPE)
    list(JOIN valid_values " " valid_values_str)
    qt_ir_add_error("Invalid value '${val}' supplied to command line option '${opt}'."
        "\nAllowed values: ${valid_values_str}\n")
endfunction()

# Sets / handles the value of a command line boolean option.
function(qt_ir_commandline_boolean arg val nextok)
    if("${val}" STREQUAL "")
        set(val "yes")
    endif()
    if(NOT val STREQUAL "yes" AND NOT val STREQUAL "no")
        message(FATAL_ERROR
            "Invalid value '${val}' given for boolean command line option '${arg}'.")
    endif()
    qt_ir_command_line_set_input("${arg}" "${val}")
endfunction()

# Sets / handles the value of a command line string option.
function(qt_ir_commandline_string arg val nextok)
    if(nextok)
        qt_ir_args_get_next_command_line_arg(val)

        if("${val}" MATCHES "^-")
            qt_ir_add_error("No value supplied to command line options '${arg}'.")
        endif()
    endif()
    qt_ir_validate_value("${arg}" "${val}" success)
    if(success)
        qt_ir_command_line_set_input("${arg}" "${val}")
    endif()
endfunction()

# Sets / handles the value of a command line void option.
# This is an option like --force, which doesn't take any arguments.
# Currently unused
function(qt_ir_commandline_void arg val nextok)
    if(NOT "${val}" STREQUAL "")
        qt_i_add_error("Command line option '${arg}' expects no argument ('${val}' given).")
    endif()
    if(DEFINED commandline_option_${arg}_value)
        set(val ${commandline_option_${arg}_value})
    endif()
    if("${val}" STREQUAL "")
        set(val yes)
    endif()
    qt_ir_command_line_set_input("${arg}" "${val}")
endfunction()

# Reads the command line arguments from the optfile_path.
function(qt_ir_get_raw_args_from_optfile optfile_path out_var)
    file(STRINGS "${optfile_path}" args)
    qt_ir_escape_semicolons(args "${args}")
    set(${out_var} "${args}" PARENT_SCOPE)
endfunction()

# Reads the optfile_path, iterates over the given command line arguments,
# sets the input for recongized options.
#
# Handles the following styles of CLI arguments:
#  --no-foo / --disable-foo
#  -no-foo / -disable-foo
#  --foo=<values>
#  --foo <values>
#  -foo <values>
#  --foo
#  -foo
#  --f
#  -f
#
# Currently handles the following types of CLI arguments:
#  string
#  boolean
#  void
#
# IGNORE_UNKNOWN_ARGS tells the function not to fail if it encounters an unknown
# option, and instead append it to a global list of unknown options.
# It is needed when the script is called from the configure script with
# configure-only-known options.
function(qt_ir_process_args_from_optfile optfile_path)
    set(options IGNORE_UNKNOWN_ARGS)
    set(oneValueArgs "")
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    qt_ir_get_raw_args_from_optfile("${optfile_path}" configure_args)
    qt_ir_set_unhandled_args("${configure_args}")

    while(1)
        qt_ir_args_has_next_command_line_arg(has_next)
        if(NOT has_next)
            break()
        endif()
        qt_ir_args_get_next_command_line_arg(arg)

        # parse out opt and val
        set(nextok FALSE)
        if(arg MATCHES "^--?(disable|no)-(.*)")
            set(opt "${CMAKE_MATCH_2}")
            set(val "no")
        elseif(arg MATCHES "^--([^=]+)=(.*)")
            set(opt "${CMAKE_MATCH_1}")
            set(val "${CMAKE_MATCH_2}")
        elseif(arg MATCHES "^--(.*)")
            set(nextok TRUE)
            set(opt "${CMAKE_MATCH_1}")
            unset(val)
        elseif(arg MATCHES "^-(.*)")
            set(nextok TRUE)
            set(opt "${CMAKE_MATCH_1}")
            unset(val)
        else()
            if(NOT arg_IGNORE_UNKNOWN_ARGS)
                qt_ir_add_error("Invalid command line parameter '${arg}'.")
            else()
                message(DEBUG "Unknown command line parameter '${arg}'. Collecting.")
                qt_ir_append_unknown_args("${arg}")
                continue()
            endif()
        endif()

        set(type "${commandline_option_${opt}_type}")

        if("${type}" STREQUAL "")
            if(NOT arg_IGNORE_UNKNOWN_ARGS)
                qt_ir_add_error("Unknown command line option '${arg}'.")
            else()
                message(DEBUG "Unknown command line option '${arg}'. Collecting.")
                qt_ir_append_unknown_args("${arg}")
                continue()
            endif()
        elseif(commandline_option_${opt}_common AND arg_IGNORE_UNKNOWN_ARGS)
            message(DEBUG "Common command line option '${arg}'. Collecting.")
            qt_ir_append_unknown_args("${arg}")
        endif()

        if(NOT COMMAND "qt_ir_commandline_${type}")
            qt_ir_add_error("Unknown type '${type}' for command line option '${opt}'.")
        endif()
        qt_ir_call_function("qt_ir_commandline_${type}" "${opt}" "${val}" "${nextok}")
    endwhile()
endfunction()

# Shows help for the command line options.
function(qt_ir_show_help)
    set(help_file "${CMAKE_CURRENT_LIST_DIR}/QtIRHelp.txt")
    if(EXISTS "${help_file}")
        file(READ "${help_file}" content)
        message("${content}")
    endif()

    message([[
General Options:
-help, -h ............ Display this help screen
]])
endfunction()

# Gets the unhandled command line args.
function(qt_ir_get_unhandled_args out_var)
    get_property(args GLOBAL PROPERTY _qt_ir_unhandled_args)
    set(${out_var} "${args}" PARENT_SCOPE)
endfunction()

# Sets the unhandled command line args.
function(qt_ir_set_unhandled_args args)
    set_property(GLOBAL PROPERTY _qt_ir_unhandled_args "${args}")
endfunction()

# Adds to the unknown command line args.
function(qt_ir_append_unknown_args args)
    set_property(GLOBAL APPEND PROPERTY _qt_ir_unknown_args ${args})
endfunction()

# Gets the unhandled command line args.
function(qt_ir_get_unknown_args out_var)
    get_property(args GLOBAL PROPERTY _qt_ir_unknown_args)
    set(${out_var} "${args}" PARENT_SCOPE)
endfunction()

# Gets the unsupported options that init-repository.pl supports, but the cmake port does
# not support.
function(qt_ir_get_unsupported_options out_var)
    set(${out_var} "${commandline_known_unsupported_options}" PARENT_SCOPE)
endfunction()

# Get the value of a command line option.
function(qt_ir_get_option_value name out_var)
    if(NOT "${commandline_option_${name}_alias}" STREQUAL "")
        set(name "${commandline_option_${name}_alias}")
    endif()

    get_property(value GLOBAL PROPERTY _qt_ir_input_${name})
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Set the value of a command line option manually.
function(qt_ir_set_option_value name value)
    if(NOT "${commandline_option_${name}_alias}" STREQUAL "")
        set(name "${commandline_option_${name}_alias}")
    endif()

    qt_ir_command_line_set_input("${name}" "${value}")
endfunction()

# Get the value of a command line option as a cmakke flag option, to be passed
# to functions that use cmake_parse_arguments.
function(qt_ir_get_option_as_cmake_flag_option cli_name cmake_option_name out_var)
    qt_ir_get_option_value("${cli_name}" bool_value)
    set(cmake_option "")
    if(bool_value)
        set(cmake_option "${cmake_option_name}")
    endif()
    set(${out_var} "${cmake_option}" PARENT_SCOPE)
endfunction()
