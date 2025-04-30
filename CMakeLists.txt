# The real minimum version will be checked by the qtbase project.
# 3.16 is the absolute minimum though.
cmake_minimum_required(VERSION 3.16...3.21)

# set QT_SUPERBUILD early, so that qtbase/.cmake.conf can check it
set(QT_SUPERBUILD TRUE)

# Include qtbase's .cmake.conf for access to QT_REPO_MODULE_VERSION
set(__qt6_qtbase_src_path "${CMAKE_CURRENT_SOURCE_DIR}/qtbase")
include("${__qt6_qtbase_src_path}/.cmake.conf")
include("${__qt6_qtbase_src_path}/cmake/QtBaseTopLevelHelpers.cmake")

qt_internal_top_level_setup_autodetect()

project(Qt
    VERSION "${QT_REPO_MODULE_VERSION}"
    DESCRIPTION "Qt Libraries"
    HOMEPAGE_URL "https://qt.io/"
    LANGUAGES CXX C
)

if(UNIX AND NOT ANDROID)
    enable_language(ASM)
endif()

qt_internal_top_level_setup_after_project()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
qt_internal_top_level_setup_cmake_module_path()

include(QtTopLevelHelpers)
include(ECMOptionalAddSubdirectory)

qt_internal_top_level_before_build_submodules()

qt_internal_find_modules(known_submodules)
# Get submodule list if not already defined
if(NOT QT_BUILD_SUBMODULES)
    if(DEFINED ENV{QT_BUILD_SUBMODULES})
        set(QT_BUILD_SUBMODULES "$ENV{QT_BUILD_SUBMODULES}")
    else()
        set(QT_BUILD_SUBMODULES "${known_submodules}")
    endif()
endif()
set(QT_BUILD_SUBMODULES "${QT_BUILD_SUBMODULES}" CACHE STRING "Submodules to build")

# Preliminary check if module should be skipped since -skip <module> or BUILD_<module>
# are provided.
set(explicitly_skipped_modules "")
foreach(module IN LISTS known_submodules)
    if(DEFINED BUILD_${module} AND NOT BUILD_${module})
        list(APPEND explicitly_skipped_modules ${module})
    endif()
endforeach()

foreach(module IN LISTS QT_BUILD_SUBMODULES)
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${module}/CMakeLists.txt)
        message(FATAL_ERROR
            "Module '${module}' cannot be found. Please double-check the "
            "spelling and try again. Or run\n"
            "`./configure -init-submodules -submodules ${module}` "
            "to clone the submodule and its dependencies.")
    endif()
endforeach()

qt_internal_sort_module_dependencies("${QT_BUILD_SUBMODULES}" QT_BUILD_SUBMODULES
    SKIP_MODULES ${explicitly_skipped_modules})

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
                    if(QT_INTERNAL_CALLED_FROM_CONFIGURE)
                        set(skip_argument "-skip ${module}")
                    else()
                        set(skip_argument "-DBUILD_${module}=OFF")
                    endif()

                    message(FATAL_ERROR "Module '${module}' depends on '${dep}', "
                        "but ${error_reason}.\n"
                        "Note: Use '${skip_argument}' to exclude it from the build.")
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

    qt_internal_top_level_after_add_subdirectory()
endforeach()

qt_internal_top_level_end()
