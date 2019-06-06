cmake_minimum_required(VERSION 3.15.0)

project(Qt
    VERSION 6.0.0
    DESCRIPTION "Qt Libraries"
    HOMEPAGE_URL "https://qt.io/"
    LANGUAGES CXX C ASM
)

# Required so we can call ctest from the root build directory
enable_testing()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/qtbase/cmake")
endif()

include(ECMOptionalAddSubdirectory)

# Use the CMake config files from the binary dir
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_BINARY_DIR}")
# Also make sure the CMake config files do not recreate the already-existing targets
if (NOT QT_BUILD_STANDALONE_TESTS)
    set(QT_NO_CREATE_TARGETS TRUE)
endif()
set(QT_SUPERBUILD TRUE)

# qtbase is always needed
add_subdirectory(qtbase)

if (NOT QT_BUILD_STANDALONE_TESTS)
    list(APPEND CMAKE_PREFIX_PATH "${QtBase_BINARY_DIR}")
endif()

ecm_optional_add_subdirectory(qtconnectivty)
ecm_optional_add_subdirectory(qtdeclarative)
ecm_optional_add_subdirectory(qtgraphicaleffects)
ecm_optional_add_subdirectory(qtimageformats)
ecm_optional_add_subdirectory(qtsvg)
ecm_optional_add_subdirectory(qtquickcontrols2)
ecm_optional_add_subdirectory(qtgamepad)
ecm_optional_add_subdirectory(qttools)


if(NOT QT_BUILD_STANDALONE_TESTS)
    # Display a summary of everything
    include(QtBuildInformation)
    qt_print_feature_summary()
    qt_print_build_instructions()
endif()
