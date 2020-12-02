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
# Each entry will be in the format dependency/sha1
function(qt_internal_parse_dependencies depends_file out_dependencies)
    file(STRINGS "${depends_file}" lines)
    set(dependencies "")
    set(dependency "")
    foreach(line IN LISTS lines)
        if(line STREQUAL "dependencies:")
            set(found_dependencies 1)
        elseif(found_dependencies)
            if(line MATCHES "^    ref: (.*)$")
                set(revision "${CMAKE_MATCH_1}")
                list(APPEND dependencies ${dependency}/${revision})
                set(dependency "")
            elseif (line MATCHES "^  (.*):$")
                if(dependency)
                    message(FATAL_ERROR "Format error in ${depends_file} - ${dependency} does not specify revision!")
                endif()
                set(dependency "${CMAKE_MATCH_1}")
                # dependencies are specified with relative path to this module
                string(REPLACE "../" "" dependency ${dependency})
            endif()
        endif()
    endforeach()
    message(DEBUG "qt_internal_parse_dependencies for ${depends_file}: ${dependencies} ${revisions}")
    set(${out_dependencies} "${dependencies}" PARENT_SCOPE)
endfunction()

# Load $module and populate $out_ordered with the submodules based on their dependencies
# $ordered carries already sorted dependencies; $out_has_dependencies is left empty
# if there are no dependencies, otherwise set to 1; Save list of dependencies for $module into
# $out_module_dependencies. List may contain duplicates, since function checks max depth
# dependencies.
# Function calls itself recursively if a dependency is found that is not yet in $ordered.
function(qt_internal_add_module_dependencies module ordered out_ordered out_has_dependencies
                                             out_module_dependencies out_revisions)
    set(depends_file "${CMAKE_CURRENT_SOURCE_DIR}/${module}/dependencies.yaml")
    if(NOT EXISTS "${depends_file}")
        set(${out_has_dependencies} "" PARENT_SCOPE)
        return()
    endif()
    set(${out_has_dependencies} "1" PARENT_SCOPE)
    set(dependencies "")
    qt_internal_parse_dependencies("${depends_file}" dependencies)
    # module hasn't been seen yet, append it
    list(FIND ordered "${module}" pindex)
    if (pindex EQUAL -1)
        list(LENGTH ordered pindex)
        list(APPEND ordered "${module}")
        list(APPEND revisions "HEAD")
    endif()
    set(modules_dependencies "")
    foreach(dependency IN LISTS dependencies)
        string(FIND "${dependency}" "/" splitindex REVERSE)
        string(SUBSTRING "${dependency}" ${splitindex} -1 revision)
        string(SUBSTRING "${revision}" 1 -1 revision)
        string(SUBSTRING "${dependency}" 0 ${splitindex} dependency)
        list(APPEND modules_dependencies "${dependency}")
        list(FIND ordered "${dependency}" dindex)
        if (dindex EQUAL -1)
            # dependency hasnt' been seen yet - load it
            list(INSERT ordered ${pindex} "${dependency}")
            list(INSERT revisions ${pindex} "${revision}")
            qt_internal_add_module_dependencies(${dependency} "${ordered}" ordered has_dependency
                                                "${out_module_dependencies}" revisions)
        elseif(dindex GREATER pindex)
            # otherwise, make sure it is before module
            list(REMOVE_AT ordered ${dindex})
            list(REMOVE_AT revisions ${dindex})
            list(INSERT ordered ${pindex} "${dependency}")
            list(INSERT revisions ${pindex} "${revision}")
        endif()
    endforeach()
    set(${out_ordered} "${ordered}" PARENT_SCOPE)
    set(${out_module_dependencies} ${${out_module_dependencies}} ${modules_dependencies} PARENT_SCOPE)
    set(${out_revisions} "${revisions}" PARENT_SCOPE)
endfunction()

# populates $out_all_ordered with the sequence of the modules that need
# to be built in order to build $modules; dependencies for each module are populated
# in variables with specified in $dependencies_map_prefix prefix
function(qt_internal_sort_module_dependencies modules out_all_ordered dependencies_map_prefix)
    set(ordered "")
    foreach(module IN LISTS modules)
        set(out_ordered "")
        if(NOT dependencies_map_prefix)
            message(FATAL_ERROR "dependencies_map_prefix is not provided")
        endif()
        set(module_dependencies_list_var_name "${dependencies_map_prefix}${module}")
        qt_internal_add_module_dependencies(${module} "${ordered}" out_ordered module_depends
                                            "${module_dependencies_list_var_name}" revisions)
        set(${module_dependencies_list_var_name}
                "${${module_dependencies_list_var_name}}" PARENT_SCOPE)
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

# does what it says, but also updates submodules
function(qt_internal_checkout module revision)
    set(swallow_output "") # unless VERBOSE, eat git output, show it in case of error
    if (NOT VERBOSE)
        list(APPEND swallow_output "OUTPUT_VARIABLE" "git_output" "ERROR_VARIABLE" "git_output")
    endif()
    message(NOTICE "Checking '${module}' out to revision '${revision}'")
    execute_process(
        COMMAND "git" "checkout" "${revision}"
        WORKING_DIRECTORY "./${module}"
        RESULT_VARIABLE git_result
        ${swallow_output}
    )
    if (git_result EQUAL 128)
        message(WARNING "${git_output}, trying detached checkout")
        execute_process(
            COMMAND "git" "checkout" "--detach" "${revision}"
            WORKING_DIRECTORY "./${module}"
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
    endif()
    if (git_result)
        message(FATAL_ERROR "Failed to check '${module}' out to '${revision}': ${git_output}")
    endif()
    execute_process(
        COMMAND "git" "submodule" "update"
        WORKING_DIRECTORY "./${module}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
    )
endfunction()

# clones or creates a worktree for $dependency, using the source of $dependent
function(qt_internal_get_dependency dependent dependency)
    set(swallow_output "") # unless VERBOSE, eat git output, show it in case of error
    if (NOT VERBOSE)
        list(APPEND swallow_output "OUTPUT_VARIABLE" "git_output" "ERROR_VARIABLE" "git_output")
    endif()

    set(gitdir "")
    set(remote "")

    # try to read the worktree source
    execute_process(
        COMMAND "git" "rev-parse" "--git-dir"
        WORKING_DIRECTORY "./${dependent}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(FIND "${git_stdout}" "${module}" index)
    string(SUBSTRING "${git_stdout}" 0 ${index} gitdir)
    string(FIND "${gitdir}" ".git/modules" index)
    if(index GREATER -1) # submodules have not been absorbed
        string(SUBSTRING "${gitdir}" 0 ${index} gitdir)
    endif()
    message(DEBUG "Will look for clones in ${gitdir}")

    execute_process(
        COMMAND "git" "remote" "get-url" "origin"
        WORKING_DIRECTORY "./${dependent}"
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_stdout
        ERROR_VARIABLE git_stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(FIND "${git_stdout}" "${dependent}.git" index)
    string(SUBSTRING "${git_stdout}" 0 ${index} remote)
    message(DEBUG "Will clone from ${remote}")

    if(EXISTS "${gitdir}.gitmodules" AND NOT EXISTS "${gitdir}${dependency}/.git")
        # super repo exists, but the submodule we need does not - try to initialize
        message(NOTICE "Initializing submodule '${dependency}' from ${gitdir}")
        execute_process(
            COMMAND "git" "submodule" "update" "--init" "${dependency}"
            WORKING_DIRECTORY "${gitdir}"
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
        if (git_result)
            # ignore errors, fall back to an independent clone instead
            message(WARNING "Failed to initialize submodule '${dependency}' from ${gitdir}")
        endif()
    endif()

    if(EXISTS "${gitdir}${dependency}")
        # for the module we want, there seems to be a clone parallel to what we have
        message(NOTICE "Adding worktree for ${dependency} from ${gitdir}${dependency}")
        execute_process(
            COMMAND "git" "worktree" "add" "--detach" "${CMAKE_CURRENT_SOURCE_DIR}/${dependency}"
            WORKING_DIRECTORY "${gitdir}/${dependency}"
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
        if (git_result)
            message(FATAL_ERROR "Failed to check '${module}' out to '${revision}': ${git_output}")
        endif()
    else()
        # we don't find the existing clone, so clone from the same remote
        message(NOTICE "Cloning ${dependency} from ${remote}${dependency}.git")
        execute_process(
            COMMAND "git" "clone" "${remote}${dependency}.git"
            WORKING_DIRECTORY "."
            RESULT_VARIABLE git_result
            ${swallow_output}
        )
        if (git_result)
            message(FATAL_ERROR "Failed to check '${module}' out to '${revision}': ${git_output}")
        endif()
    endif()
endfunction()

# evaluates the dependencies for $module, and checks all dependencies
# out so that it is a consistent set
function(qt_internal_sync_to module)
    if(ARGN)
        set(revision "${ARGV1}")
        # special casing "." as the target module - checkout all out to $revision
        if("${module}" STREQUAL ".")
            qt_internal_find_modules(modules)
            foreach(module IN LISTS modules)
                qt_internal_checkout("${module}" "${revision}")
            endforeach()
            return()
        endif()
    else()
        set(revision "HEAD")
    endif()
    qt_internal_checkout("${module}" "${revision}")

    set(revision "")
    set(checkedout "1")
    # Load all dependencies for $module, then iterate over the dependencies in reverse order,
    # and check out the first that isn't already at the required revision.
    # Repeat everything (we need to reload dependencies after each checkout) until no more checkouts
    # are done.
    while(${checkedout})
        set(dependencies "")
        set(revisions "")
        set(prefix "")
        qt_internal_add_module_dependencies(${module} "${dependencies}" dependencies has_dependencies prefix revisions)
        message(DEBUG "${module} dependencies: ${dependencies}")
        message(DEBUG "${module} revisions   : ${revisions}")

        if (NOT has_dependencies)
            message(NOTICE "Module ${module} has no dependencies")
            return()
        endif()

        list(LENGTH dependencies count)
        math(EXPR count "${count} - 1")
        set(checkedout 0)
        foreach(i RANGE ${count} 0 -1 )
            list(GET dependencies ${i} dependency)
            list(GET revisions ${i} revision)
            if ("${revision}" STREQUAL "HEAD")
                message(DEBUG "Not changing checked out revision of ${dependency}")
                continue()
            endif()

            if(NOT EXISTS "./${dependency}")
                message(DEBUG "No worktree for '${dependency}' found in '${CMAKE_CURRENT_SOURCE_DIR}'")
                qt_internal_get_dependency("${module}" "${dependency}")
            endif()

            execute_process(
                COMMAND "git" "rev-parse" "HEAD"
                WORKING_DIRECTORY "./${dependency}"
                RESULT_VARIABLE git_result
                OUTPUT_VARIABLE git_stdout
                ERROR_VARIABLE git_stderr
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if (git_result)
                message(WARNING "${git_stdout}")
                message(FATAL_ERROR "Failed to get current HEAD of '${dependency}': ${git_stderr}")
            endif()
            if ("${git_stdout}" STREQUAL "${revision}")
                continue()
            endif()

            qt_internal_checkout("${dependency}" "${revision}")
            set(checkedout 1)
            break()
        endforeach()
    endwhile()
endfunction()
