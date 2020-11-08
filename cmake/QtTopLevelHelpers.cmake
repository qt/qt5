# Populates $out_module_list with all subdirectories that have a CMakeLists.txt file
function(qt_internal_find_modules out_module_list)
    set(module_list "")
    file(GLOB directories LIST_DIRECTORIES true RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *)
    foreach(directory IN LISTS directories)
        if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${directory}"
           AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${directory}/CMakeLists.txt")
            list(APPEND module_list "${directory}")
        endif()
    endforeach()
    message(DEBUG "qt_internal_find_modules: ${module_list}")
    set(${out_module_list} "${module_list}" PARENT_SCOPE)
endfunction()

# poor man's yaml parser, populating $out_dependencies with all dependencies
# in the $depends_file
function(qt_internal_parse_dependencies depends_file out_dependencies)
    file(STRINGS "${depends_file}" lines)
    set(dependencies "")
    foreach(line IN LISTS lines)
        if(line STREQUAL "dependencies:")
            set(found_dependencies 1)
        elseif(found_dependencies AND line MATCHES "^  (.*):$")
            set(dependency ${CMAKE_MATCH_1})
            # dependencies are specified with relative path to this module
            string(REPLACE "../" "" dependency ${dependency})
            list(APPEND dependencies ${dependency})
        endif()
    endforeach()
    message(DEBUG "qt_internal_parse_dependencies for ${depends_file}: ${module_list}")
    set(${out_dependencies} "${dependencies}" PARENT_SCOPE)
endfunction()

# Load $module and populate $out_ordered with the submodules based on their dependencies
# $ordered carries already sorted dependencies; $out_has_dependencies is left empty
# if there are no dependencies, otherwise set to 1
# Function calls itself recursively if a dependency is found that is not yet in $ordered.
function(qt_internal_add_module_dependencies module ordered out_ordered out_has_dependencies)
    set(depends_file "${CMAKE_CURRENT_SOURCE_DIR}/${module}/dependencies.yaml")
    if(NOT EXISTS "${depends_file}")
        set(${out_has_dependencies} "" PARENT_SCOPE)
        return()
    endif()
    set(${out_has_dependencies} "1" PARENT_SCOPE)
    set(dependencies "")
    qt_internal_parse_dependencies(${depends_file} dependencies)
    # module hasn't been seen yet, append it
    list(FIND ordered "${module}" pindex)
    if (pindex EQUAL -1)
        list(LENGTH ordered pindex)
        list(APPEND ordered ${module})
    endif()
    foreach(dependency IN LISTS dependencies)
        list(FIND ordered "${dependency}" dindex)
        if (dindex EQUAL -1)
            # dependency hasnt' been seen yet - load it
            list(INSERT ordered ${pindex} "${dependency}")
            qt_internal_add_module_dependencies(${dependency} "${ordered}" ordered has_dependency)
        elseif(dindex GREATER pindex)
            # otherwise, make sure it is before module
            list(REMOVE_AT ordered ${dindex})
            list(INSERT ordered ${pindex} "${dependency}")
        endif()
    endforeach()
    set(${out_ordered} "${ordered}" PARENT_SCOPE)
endfunction()

# populates $out_all_ordered with the sequence of the modules that need
# to be built in order to build $modules
function(qt_internal_sort_module_dependencies modules out_all_ordered)
    set(ordered "")
    foreach(module IN LISTS modules)
        set(out_ordered "")
        qt_internal_add_module_dependencies(${module} "${ordered}" out_ordered module_depends)
        if(NOT module_depends)
            list(APPEND no_dependencies "${module}")
        endif()
        set(ordered "${out_ordered}")
    endforeach()
    if (no_dependencies)
        list(APPEND ordered "${no_dependencies}")
    endif()
    message(DEBUG "qt_internal_parse_dependencies sorted ${modules}: ${ordered}")
    set(${out_all_ordered} "${ordered}" PARENT_SCOPE)
endfunction()
