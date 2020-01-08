cmake_minimum_required(VERSION 3.15.0)

project(Qt
    VERSION 6.0.0
    DESCRIPTION "Qt Libraries"
    HOMEPAGE_URL "https://qt.io/"
    LANGUAGES CXX C ASM
)

# Required so we can call ctest from the root build directory
enable_testing()

set(qt_module_prop_prefix "__qt_prop_")
function(extract_git_submodules out_module_list)
    set(modules "")
    set(current_module "")
    set(module_list "")
    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/.gitmodules" lines)
    foreach(line IN LISTS lines)
        string(REGEX REPLACE "^\\[submodule \"([^\"]+)\"\\]$" "\\1" module ${line})
        if (NOT module STREQUAL line)
            list(APPEND modules ${modules})
            set(current_module ${module})
            list(APPEND module_list ${module})
        else()
            string(REGEX REPLACE "^\t([^ =]+) *=.*$" "\\1" prop ${line})
            if (NOT prop STREQUAL line)
                string(REGEX REPLACE "^[^=]+= *" "" value ${line})
                string(REPLACE " " ";" value ${value})
                set("${qt_module_prop_prefix}${current_module}_${prop}" "${value}" PARENT_SCOPE)
            else()
                message(FATAL_ERROR "Malformed line ${CMAKE_CURRENT_SOURCE_DIR}/.gitmodules: ${line}")
            endif()
        endif()
    endforeach()
    set(${out_module_list} ${module_list} PARENT_SCOPE)
endfunction()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/qtbase/cmake")
endif()

include(ECMOptionalAddSubdirectory)
include(TopologicalSort)

# Use the CMake config files from the binary dir
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_BINARY_DIR}")
# Also make sure the CMake config files do not recreate the already-existing targets
if (NOT QT_BUILD_STANDALONE_TESTS)
    set(QT_NO_CREATE_TARGETS TRUE)
endif()
set(QT_SUPERBUILD TRUE)

# Get submodules list
extract_git_submodules(git_module_list)
foreach(module IN LISTS git_module_list)
    # Prepare a list of dependencies to be fed into topological sort
    set("${qt_module_prop_prefix}${module}_all_dependencies"
            ${${qt_module_prop_prefix}${module}_depends}
            ${${qt_module_prop_prefix}${module}_recommends}
            ${${qt_module_prop_prefix}${module}_serialize}
    )
endforeach()

# Sort by dependencies
topological_sort(git_module_list "${qt_module_prop_prefix}" "_all_dependencies")

# Check for unknown modules
foreach(module IN LISTS git_module_list)
    foreach(dep IN LISTS "${qt_module_prop_prefix}${module}_all_dependencies")
        if (NOT dep IN_LIST git_module_list)
            message(FATAL_ERROR "Module '${module}' depends on undeclared module '${dep}'")
        endif()
    endforeach()
endforeach()

# qtbase is always needed
list(REMOVE_ITEM git_module_list qtbase)
add_subdirectory(qtbase)

if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_PREFIX_PATH "${QtBase_BINARY_DIR}")
endif()

foreach(module IN LISTS git_module_list)
    ecm_optional_add_subdirectory(${module})
endforeach()

# Check for unmet dependencies
foreach(module IN LISTS git_module_list)
    foreach(dep IN LISTS "${qt_module_prop_prefix}${module}_depends")
        if (dep STREQUAL qtbase)
            # Always available skip
            continue()
        endif()
        if (DEFINED BUILD_${module} AND BUILD_${module})
            if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dep}/CMakeLists.txt")
                message(FATAL_ERROR "Module '${module} depends on '${dep}', but ${deps}'s CMakeLists.txt couldn't be found.\n")
            endif()
            if(NOT BUILD_${dep})
                message(FATAL_ERROR "Module '${module} depends on '${dep}', but ${deps} will not be built.\n")
            endif()
        endif()
    endforeach()
endforeach()


if(NOT QT_BUILD_STANDALONE_TESTS)
    # Display a summary of everything
    include(QtBuildInformation)
    qt_print_feature_summary()
    qt_print_build_instructions()
endif()
