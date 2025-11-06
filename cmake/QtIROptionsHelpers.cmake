# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# Declare command line options known to init-repository.
macro(qt_ir_set_known_command_line_options)
    # Implemented options

    # Note alternates is a qt specific option name, but it uses
    # git submodule's --reference option underneath which also implies --shared.
    # It essentially uses the git object storage of another repo, to avoid
    # cloning the same objects and thus saving space.
    qt_ir_commandline_option(alternates TYPE string)

    qt_ir_commandline_option(berlin TYPE boolean)
    qt_ir_commandline_option(branch TYPE boolean)
    qt_ir_commandline_option(codereview-username TYPE string)
    qt_ir_commandline_option(codereview-https TYPE boolean)
    qt_ir_commandline_option(copy-objects TYPE boolean)
    qt_ir_commandline_option(fetch TYPE boolean DEFAULT_VALUE yes)
    qt_ir_commandline_option(force SHORT_NAME f TYPE boolean)
    qt_ir_commandline_option(force-hooks TYPE boolean)
    qt_ir_commandline_option(help SHORT_NAME h TYPE boolean)
    qt_ir_commandline_option(ignore-submodules TYPE boolean)
    qt_ir_commandline_option(mirror TYPE string)
    qt_ir_commandline_option(module-subset TYPE string)
    qt_ir_commandline_option(optional-deps TYPE boolean DEFAULT_VALUE yes)
    qt_ir_commandline_option(oslo TYPE boolean)
    qt_ir_commandline_option(perl-identical-output TYPE boolean)
    qt_ir_commandline_option(perl-init-check TYPE boolean)
    qt_ir_commandline_option(quiet SHORT_NAME q TYPE boolean)
    qt_ir_commandline_option(resolve-deps TYPE boolean DEFAULT_VALUE yes)
    qt_ir_commandline_option(update TYPE boolean DEFAULT_VALUE yes)
    qt_ir_commandline_option(verbose TYPE boolean COMMON)

    # These are used when init-repository is called from configure.
    qt_ir_commandline_option(from-configure TYPE boolean)
    # Implies force.
    qt_ir_commandline_option(init-submodules TYPE boolean)
    # We alias qtbase's submodules option to init-repository module-subset.
    qt_ir_commandline_option(submodules ALIAS module-subset TYPE string)

    set_property(GLOBAL PROPERTY _qt_ir_known_command_line_options "${commandline_known_options}")
endmacro()

# Gets list of known command line options.
function(qt_ir_get_known_command_line_options out_var)
    get_property(values GLOBAL PROPERTY _qt_ir_known_command_line_options)
    set(${out_var} "${values}" PARENT_SCOPE)
endfunction()
