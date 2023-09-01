# The real minimum version will be checked by the qtbase project.
# 3.16 is the absolute minimum though.
cmake_minimum_required(VERSION 3.16...3.21)


# set QT_SUPERBUILD early, so that qtbase/.cmake.conf can check it
set(QT_SUPERBUILD TRUE)

# Include qtbase's .cmake.conf for access to QT_REPO_MODULE_VERSION
set(__qt6_qtbase_src_path "${CMAKE_CURRENT_SOURCE_DIR}/qtbase")
include("${__qt6_qtbase_src_path}/.cmake.conf")

# Run platform auto-detection /before/ the first project() call and thus
# before the toolchain file is loaded.
# Don't run auto-detection when doing standalone tests. In that case, the detection
# results are taken from either QtBuildInternals or the qt.toolchain.cmake file.

if(NOT QT_BUILD_STANDALONE_TESTS)
    include("${__qt6_qtbase_src_path}/cmake/QtAutoDetect.cmake")
endif()

project(Qt
    VERSION "${QT_REPO_MODULE_VERSION}"
    DESCRIPTION "Qt Libraries"
    HOMEPAGE_URL "https://qt.io/"
    LANGUAGES CXX C ASM
)

# Required so we can call ctest from the root build directory
enable_testing()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_MODULE_PATH "${__qt6_qtbase_src_path}/cmake")
    list(APPEND CMAKE_MODULE_PATH
        "${__qt6_qtbase_src_path}/cmake/3rdparty/extra-cmake-modules/find-modules")
    list(APPEND CMAKE_MODULE_PATH "${__qt6_qtbase_src_path}/cmake/3rdparty/kwin")
endif()

include(QtTopLevelHelpers)
include(ECMOptionalAddSubdirectory)

# Also make sure the CMake config files do not recreate the already-existing targets
if (NOT QT_BUILD_STANDALONE_TESTS)
    set(QT_NO_CREATE_TARGETS TRUE)
endif()

# Get submodule list if not already defined
if(NOT QT_BUILD_SUBMODULES)
    if(DEFINED ENV{QT_BUILD_SUBMODULES})
        set(QT_BUILD_SUBMODULES "$ENV{QT_BUILD_SUBMODULES}")
    else()
        qt_internal_find_modules(QT_BUILD_SUBMODULES)
    endif()
endif()
set(QT_BUILD_SUBMODULES "${QT_BUILD_SUBMODULES}" CACHE STRING "Submodules to build")

foreach(module IN LISTS QT_BUILD_SUBMODULES)
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${module}/CMakeLists.txt)
        message(FATAL_ERROR
            "Module '${module}' cannot be found. Please double-check the "
            "spelling and try again. Or run `./init-repository` to get "
            "the submodules.")
    endif()
endforeach()

qt_internal_sort_module_dependencies("${QT_BUILD_SUBMODULES}" QT_BUILD_SUBMODULES)

foreach(module IN LISTS QT_BUILD_SUBMODULES)
    # Check for unmet dependencies
    if(NOT DEFINED BUILD_${module} OR BUILD_${module})
        message(STATUS "Checking dependencies of submodule '${module}'")
        get_property(required_deps GLOBAL PROPERTY QT_REQUIRED_DEPS_FOR_${module})
        get_property(dependencies GLOBAL PROPERTY QT_DEPS_FOR_${module})
        foreach(dep IN LISTS dependencies)
            if (dep STREQUAL "qtbase")
                # Always available skip
                continue()
            endif()

            set(required FALSE)
            if(dep IN_LIST required_deps)
                set(required TRUE)
            endif()

            set(error_reason "")
            if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dep}/CMakeLists.txt")
                set(error_reason "${dep}'s CMakeLists.txt couldn't be found")
            elseif(DEFINED BUILD_${dep} AND NOT BUILD_${dep})
                set(error_reason "building '${dep}' was explicitly disabled")
            endif()

            if(NOT error_reason STREQUAL "")
                if(required)
                    message(FATAL_ERROR "Module '${module}' depends on '${dep}', "
                        "but ${error_reason}.\n"
                        "Note: Use '-skip ${module}' to exclude it from the build.")
                else()
                    message(STATUS "Skipping optional dependency '${dep}' of '${module}', "
                        "because ${error_reason}.")
                endif()
            endif()
        endforeach()
    endif()
endforeach()

if(NOT DEFINED CMAKE_MESSAGE_CONTEXT_SHOW)
    set(CMAKE_MESSAGE_CONTEXT_SHOW TRUE)
endif()

foreach(module IN LISTS QT_BUILD_SUBMODULES)
    message(STATUS "Configuring submodule '${module}'")
    ecm_optional_add_subdirectory("${module}")

    if(module STREQUAL "qtbase")
        if (NOT QT_BUILD_STANDALONE_TESTS)
            list(APPEND CMAKE_PREFIX_PATH "${QtBase_BINARY_DIR}/${INSTALL_LIBDIR}/cmake")
            list(APPEND CMAKE_FIND_ROOT_PATH "${QtBase_BINARY_DIR}")
        endif()
    endif()
endforeach()

if(NOT QT_BUILD_STANDALONE_TESTS)
    # Display a summary of everything
    include(QtBuildInformation)
    include(QtPlatformSupport)
    qt_print_feature_summary()
    qt_print_build_instructions()
endif()
