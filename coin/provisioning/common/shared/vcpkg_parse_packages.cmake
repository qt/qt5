#!/usr/bin/cmake -P

cmake_minimum_required(VERSION 3.19)

message("VCPKG_EXECUTABLE: ${VCPKG_EXECUTABLE}")
if(NOT VCPKG_EXECUTABLE OR NOT EXISTS "${VCPKG_EXECUTABLE}" OR NOT OUTPUT OR NOT VCPKG_INSTALL_ROOT)
    message(FATAL_ERROR "Usage: \ncmake -DVCPKG_EXECUTABLE=<path/to/vcpkg/executable>"
        " -DOUTPUT=<path/to/versions.txt> -DVCPKG_INSTALL_ROOT=<path/to/install/root>"
        " -P vcpkg_parse_packages.cmake"
    )
endif()
execute_process(COMMAND "${VCPKG_EXECUTABLE}"
    "list"  "--x-install-root=${VCPKG_INSTALL_ROOT}" "--x-json" OUTPUT_VARIABLE result)

string(JSON element_count LENGTH "${result}")

file(STRINGS "${OUTPUT}" output_data)
math(EXPR last_index "${element_count} - 1")
foreach(i RANGE 0 ${last_index})
    string(JSON package MEMBER "${result}" "${i}")

    # Extract the package name from <package name>:<triplet> pair
    if(NOT package MATCHES "^([^:]+):.+$")
        continue()
    endif()

    # Skip vcpkg internal tools
    set(package_name "${CMAKE_MATCH_1}")
    if(package_name MATCHES "^vcpkg-.+$")
        continue()
    endif()

    string(JSON package_info GET "${result}" "${package}")
    string(JSON version GET "${package_info}" "version")

    string(STRIP "${package}" package)
    string(STRIP "${version}" version)
    # Store the package information for the particular triplet
    list(APPEND output_data "vcpkg ${package} = ${version}")
endforeach()

if(output_data)
    list(JOIN output_data "\n" output_data)
    file(WRITE "${OUTPUT}" "${output_data}\n")
endif()
