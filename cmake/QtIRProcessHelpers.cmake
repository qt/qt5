# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# A low-level execute_process wrapper that can be used to execute a single command
# while controlling the verbosity and error handling.
function(qt_ir_execute_process)
    set(options
        QUIET
    )
    set(oneValueArgs
        WORKING_DIRECTORY
        OUT_RESULT_VAR
        OUT_OUTPUT_VAR
        OUT_ERROR_VAR
    )
    set(multiValueArgs
        COMMAND_ARGS
        EP_EXTRA_ARGS
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT arg_COMMAND_ARGS)
        message(FATAL_ERROR "Missing arguments to qt_ir_execute_process")
    endif()

    if(arg_WORKING_DIRECTORY)
        set(working_dir_value "${arg_WORKING_DIRECTORY}")
    else()
        set(working_dir_value ".")
    endif()
    set(working_dir WORKING_DIRECTORY "${working_dir_value}")

    set(result_variable "")
    if(arg_OUT_RESULT_VAR)
        set(result_variable RESULT_VARIABLE proc_result)
    endif()

    set(swallow_output "")
    if(arg_OUT_OUTPUT_VAR OR arg_QUIET)
        list(APPEND swallow_output OUTPUT_VARIABLE proc_output)
    endif()
    if(arg_OUT_ERROR_VAR OR arg_QUIET)
        list(APPEND swallow_output ERROR_VARIABLE proc_error)
    endif()
    if(NOT arg_QUIET)
        set(working_dir_message "")

        qt_ir_is_verbose(verbose)
        if(verbose)
            set(working_dir_message "    current working dir: ")
            if(NOT working_dir_value STREQUAL ".")
                string(APPEND working_dir_message "${working_dir_value}")
            endif()
        endif()

        qt_ir_prettify_command_args(command_args_string "${arg_COMMAND_ARGS}")
        message("+ ${command_args_string}${working_dir_message}")
    endif()

    qt_ir_unescape_semicolons(arg_COMMAND_ARGS "${arg_COMMAND_ARGS}")
    execute_process(
        COMMAND ${arg_COMMAND_ARGS}
        ${working_dir}
        ${result_variable}
        ${swallow_output}
        ${arg_EP_EXTRA_ARGS}
    )

    if(arg_OUT_RESULT_VAR)
        set(${arg_OUT_RESULT_VAR} "${proc_result}" PARENT_SCOPE)
    endif()
    if(arg_OUT_OUTPUT_VAR)
        set(${arg_OUT_OUTPUT_VAR} "${proc_output}" PARENT_SCOPE)
    endif()
    if(arg_OUT_ERROR_VAR)
        set(${arg_OUT_ERROR_VAR} "${proc_error}" PARENT_SCOPE)
    endif()
endfunction()

# Guards the escaped semicolon sequences with square brackets.
function(qt_ir_escape_semicolons out_var input_string)
    string(REPLACE "\;" "[[;]]" ${out_var} "${input_string}")
    set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

# Removes the square bracket guards around semicolons and escape them.
function(qt_ir_unescape_semicolons out_var input_string)
    string(REPLACE "[[;]]" "\;" ${out_var} "${input_string}")
    set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

# Converts the command line arguments to a nice bash runnable string
function(qt_ir_prettify_command_args output args)
    list(JOIN args " " ${output})
    qt_ir_unescape_semicolons(${output} "${${output}}")
    set(${output} "${${output}}" PARENT_SCOPE)
endfunction()

# A higher level execute_process wrapper that can be used to execute a single command
# that is a bit more opinionated and expects options related to init-repository
# functionality.
# It handles queietness, error handling and logging.
# It also allows for slightly more compact syntax for calling processes.
function(qt_ir_execute_process_and_log_and_handle_error)
    set(options
        NO_HANDLE_ERROR
        FORCE_VERBOSE
        FORCE_QUIET
    )
    set(oneValueArgs
        WORKING_DIRECTORY
        OUT_RESULT_VAR
        OUT_OUTPUT_VAR
        OUT_ERROR_VAR
        ERROR_MESSAGE
    )
    set(multiValueArgs
        COMMAND_ARGS
        EP_EXTRA_ARGS
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    qt_ir_get_option_value(quiet quiet)
    set(quiet_option "")
    if((quiet OR arg_FORCE_QUIET) AND NOT arg_FORCE_VERBOSE)
        set(quiet_option "QUIET")
    endif()

    set(working_dir "")
    if(arg_WORKING_DIRECTORY)
        set(working_dir WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}")
    endif()

    set(extra_args "")
    if(arg_EP_EXTRA_ARGS)
        set(extra_args EP_EXTRA_ARGS "${arg_EP_EXTRA_ARGS}")
    endif()

    set(out_output_var "")
    if(arg_OUT_OUTPUT_VAR OR quiet)
        set(out_output_var OUT_OUTPUT_VAR proc_output)
    endif()

    set(out_error_var "")
    if(arg_OUT_ERROR_VAR OR quiet)
        set(out_error_var OUT_ERROR_VAR proc_error)
    endif()

    qt_ir_execute_process(
        ${quiet_option}
        COMMAND_ARGS ${arg_COMMAND_ARGS}
        OUT_RESULT_VAR proc_result
        ${extra_args}
        ${working_dir}
        ${out_output_var}
        ${out_error_var}
    )

    if(NOT proc_result EQUAL 0 AND NOT arg_NO_HANDLE_ERROR)
        set(error_message "")
        if(arg_ERROR_MESSAGE)
            set(error_message "${arg_ERROR_MESSAGE}\n")
        endif()

        qt_ir_prettify_command_args(cmd "${arg_COMMAND_ARGS}")
        string(APPEND error_message "${cmd} exited with status: ${proc_result}\n")
        if(proc_output)
            string(APPEND error_message "stdout: ${proc_output}\n")
        endif()
        if(proc_error)
            string(APPEND error_message "stderr: ${proc_error}\n")
        endif()
        message(FATAL_ERROR "${error_message}")
    endif()

    if(arg_OUT_RESULT_VAR)
        set(${arg_OUT_RESULT_VAR} "${proc_result}" PARENT_SCOPE)
    endif()
    if(arg_OUT_OUTPUT_VAR)
        set(${arg_OUT_OUTPUT_VAR} "${proc_output}" PARENT_SCOPE)
    endif()
    if(arg_OUT_ERROR_VAR)
        set(${arg_OUT_ERROR_VAR} "${proc_error}" PARENT_SCOPE)
    endif()
endfunction()
