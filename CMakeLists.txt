set(__qt6_qtbase_src_path "${CMAKE_CURRENT_SOURCE_DIR}/qtbase")

include("${__qt6_qtbase_src_path}/.cmake.conf")
include("${__qt6_qtbase_src_path}/cmake/QtCMakeVersionHelpers.cmake")
qt_internal_check_for_suitable_cmake_version()
qt_internal_get_computed_minimum_cmake_version(__qt_minimum_cmake_version)
cmake_minimum_required(VERSION ${__qt_minimum_cmake_version})

include("${__qt6_qtbase_src_path}/cmake/QtAutoDetect.cmake")

project(Qt
    VERSION 6.1.0
    DESCRIPTION "Qt Libraries"
    HOMEPAGE_URL "https://qt.io/"
    LANGUAGES CXX C ASM
)

# Required so we can call ctest from the root build directory
enable_testing()

set(qt_module_prop_prefix "__qt_prop_")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_MODULE_PATH "${__qt6_qtbase_src_path}/cmake")
    list(APPEND CMAKE_MODULE_PATH
        "${__qt6_qtbase_src_path}/cmake/3rdparty/extra-cmake-modules/find-modules")
    list(APPEND CMAKE_MODULE_PATH "${__qt6_qtbase_src_path}/cmake/3rdparty/kwin")
endif()

include("QtTopLevelHelpers")
include(ECMOptionalAddSubdirectory)

# Also make sure the CMake config files do not recreate the already-existing targets
if (NOT QT_BUILD_STANDALONE_TESTS)
    set(QT_NO_CREATE_TARGETS TRUE)
endif()
set(QT_SUPERBUILD TRUE)

# Get submodule list if not already defined
if (NOT BUILD_SUBMODULES)
    qt_internal_find_modules(BUILD_SUBMODULES)
endif()

set(qt_module_dependency_map_prefix "__qt_module_dependencies_")
qt_internal_sort_module_dependencies("${BUILD_SUBMODULES}" BUILD_SUBMODULES
                                     "${qt_module_dependency_map_prefix}")

foreach(module IN LISTS BUILD_SUBMODULES)
    # Check for unmet dependencies
    if(NOT DEFINED BUILD_${module} OR BUILD_${module})
        message(NOTICE "Check dependencies of '${module}'")
        foreach(dep IN LISTS "${qt_module_dependency_map_prefix}${module}")
            if (dep STREQUAL "qtbase")
                # Always available skip
                continue()
            endif()
            if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dep}/CMakeLists.txt")
                message(FATAL_ERROR "Module '${module}' depends on '${dep}', but ${dep}'s \
                CMakeLists.txt couldn't be found.\nNote: Use '-skip ${module}' to exclude it \
                from build.\n")
            endif()
            if(DEFINED BUILD_${dep} AND NOT BUILD_${dep})
                message(FATAL_ERROR "Module '${module}' depends on '${dep}', but '${dep}' \
                will not be built.\nNote: Use '-skip ${module}' to exclude it from build.\n")
            endif()
        endforeach()
    endif()
endforeach()

foreach(module IN LISTS BUILD_SUBMODULES)
    message(NOTICE "Configuring '${module}'")
    ecm_optional_add_subdirectory("${module}")

    if(module STREQUAL "qtbase")
        if (NOT QT_BUILD_STANDALONE_TESTS)
            list(APPEND CMAKE_PREFIX_PATH "${QtBase_BINARY_DIR}/lib/cmake")
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
