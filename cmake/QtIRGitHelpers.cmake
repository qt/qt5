# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# Returns the git version.
function(qt_ir_get_git_version out_var)
    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)

    set(extra_args "")
    if(perl_identical_output_for_tests)
        set(extra_args FORCE_QUIET)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git version ${extra_args}
        OUT_OUTPUT_VAR git_output
        ERROR_MESSAGE "Failed to retrieve git version")

    string(REGEX REPLACE "^git version ([0-9]+)\\.([0-9]+)\\.([0-9]+).*$" "\\1.\\2.\\3"
        version "${git_output}")
    if(NOT version)
        message(FATAL_ERROR "Failed to parse git version: ${git_output}, expected [d]+.[d]+.[d]+")
    endif()

    set(${out_var} "${version}" PARENT_SCOPE)
endfunction()

# Returns the git version, but caches the result in a global property.
function(qt_ir_get_git_version_cached out_var)
    get_property(version GLOBAL PROPERTY _qt_git_version)
    if(NOT version)
        qt_ir_get_git_version(version)
    endif()

    set_property(GLOBAL PROPERTY _qt_git_version "${version}")

    set(${out_var} "${version}" PARENT_SCOPE)
endfunction()

# Returns whether git supports the git submodule --progress option.
function(qt_ir_is_git_progress_supported out_var)
    qt_ir_get_git_version_cached(version)
    if(version VERSION_GREATER_EQUAL "2.11")
        set(${out_var} TRUE PARENT_SCOPE)
    else()
        set(${out_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

# Get the mirror with trailing slashes removed.
function(qt_ir_get_mirror out_var)
    qt_ir_get_option_value(mirror mirror)
    qt_ir_get_option_value(berlin berlin)
    qt_ir_get_option_value(oslo oslo)

    if(berlin)
        set(mirror "git://hegel/qt/")
    elseif(oslo)
        set(mirror "git://qilin/qt/")
    endif()

    # Replace any double trailing slashes from end of mirror
    string(REGEX REPLACE "//+$" "/" mirror "${mirror}")

    set(${out_var} "${mirror}" PARENT_SCOPE)
endfunction()

# Sets up the commit template for a submodule.
function(qt_ir_setup_commit_template commit_template_dir working_directory)
    set(template "${commit_template_dir}/.commit-template")
    if(NOT EXISTS "${template}")
        return()
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git config commit.template "${template}"
        ERROR_MESSAGE "Failed to setup commit template"
        WORKING_DIRECTORY "${working_directory}")
endfunction()

# Initializes a list of submodules. This does not them, but just
# sets up the .git/config file submodule.$submodule_name.url based on the .gitmodules template file.
function(qt_ir_run_git_submodule_init submodules working_directory)
    set(submodule_dirs "")
    foreach(submodule_name IN LISTS submodules)
        set(submodule_path "${${prefix}_${submodule_name}_path}")
        list(APPEND submodule_dirs "${submodule_name}")
    endforeach()
    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git submodule init ${submodule_dirs}
        ERROR_MESSAGE "Failed to git submodule init ${submodule_dirs}"
        WORKING_DIRECTORY "${working_directory}")

    qt_ir_setup_commit_template("${working_directory}" "${working_directory}")
endfunction()

# Add gerrit remotes to the repository located in the working_directory.
# repo_relative_url is the relative URL of the repository.
# Examples:
# - qt5
# - qttools.git
# - ../playground/qlitehtml.git
# - ../qt/qttools-litehtml.git
function(qt_ir_add_git_remotes repo_relative_url working_directory)
    set(gerrit_ssh_base "ssh://@USER@codereview.qt-project.org@PORT@/")
    set(gerrit_https_base "https://@USER@codereview.qt-project.org@AUTH@/")

    qt_ir_get_option_value(codereview-username username)
    qt_ir_get_option_value(codereview-https https)

    if(https)
        set(gerrit_repo_url "${gerrit_https_base}")
    else()
        set(gerrit_repo_url "${gerrit_ssh_base}")
    endif()

    # If given a username, make a "verbose" remote.
    # Otherwise, rely on proper SSH configuration.
    if(username)
        string(REPLACE "@USER@" "${username}@" gerrit_repo_url "${gerrit_repo_url}")
        string(REPLACE "@PORT@" ":29418" gerrit_repo_url "${gerrit_repo_url}")
        string(REPLACE "@AUTH@" "/a" gerrit_repo_url "${gerrit_repo_url}")
    else()
        string(REPLACE "@USER@" "" gerrit_repo_url "${gerrit_repo_url}")
        string(REPLACE "@PORT@" "" gerrit_repo_url "${gerrit_repo_url}")
        string(REPLACE "@AUTH@" ""   gerrit_repo_url "${gerrit_repo_url}")
    endif()

    set(namespace "qt")
    set(repo_relative_url_with_namespace "${namespace}/${repo_relative_url}")
    qt_ir_normalize_git_url("${repo_relative_url_with_namespace}" normalized_url)
    string(APPEND gerrit_repo_url "${normalized_url}")

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git config remote.gerrit.url "${gerrit_repo_url}"
        ERROR_MESSAGE "Failed to set gerrit repo url"
        WORKING_DIRECTORY "${working_directory}")

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS
            git config remote.gerrit.fetch "+refs/heads/*:refs/remotes/gerrit/*" "/heads/"
        ERROR_MESSAGE "Failed to set gerrit repo fetch refspec"
        WORKING_DIRECTORY "${working_directory}")
endfunction()

# Handles the copy-objects option, which is used to detach alternates.
# A copy of all git objects are made from the alternate repository to the current repository.
# Then the alternates reference is removed.
function(qt_ir_handle_detach_alternates working_directory)
    qt_ir_get_option_value(copy-objects should_detach)
    if(NOT should_detach)
        return()
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git repack -a
        ERROR_MESSAGE "Failed to repack objects to detach alternates"
        WORKING_DIRECTORY "${working_directory}")

    set(alternates_path "${working_directory}/.git/objects/info/alternates")
    if(EXISTS "${alternates_path}")
        file(REMOVE "${alternates_path}")
        if(EXISTS "${alternates_path}")
            message(FATAL_ERROR "Failed to remove alternates file: ${alternates_path}")
        endif()
    endif()
endfunction()

# Clones a submodule, unless it was previously cloned.
# When cloning, checks out a specific branch if requested, otherwise does not
# checkout any files yet, mimicking a bare repo.
# Sets up an alternates link if requested.
# Detaches alternates if requested.
# Fetches refs if requested.
# Adds a gerrit git remote.
# Sets up the commit template for the submodule.
function(qt_ir_clone_one_submodule submodule_name)
    set(options
        CHECKOUT_BRANCH
        FETCH
    )
    set(oneValueArgs
        ALTERNATES
        BASE_URL
        WORKING_DIRECTORY
    )
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    qt_ir_get_working_directory_from_arg(working_directory)

    set(clone_args "")
    set(submodule_path "${${prefix}_${submodule_name}_path}")

    if(arg_ALTERNATES)
        # alternates is a qt5 repo, so the submodule will be under that.
        set(alternates_dir "${arg_ALTERNATES}/${submodule_path}/.git")
        if(EXISTS "${alternates_dir}")
            list(APPEND clone_args --reference "${arg_ALTERNATES}/${submodule_path}")
        else()
            message(WARNING "'${arg_ALTERNATES}/${submodule_path}' not found, "
                "ignoring alternate for this submodule")
        endif()
    endif()

    if(NOT EXISTS "${working_directory}/${submodule_path}/.git")
        set(should_clone TRUE)
    else()
        set(should_clone FALSE)
    endif()

    set(submodule_base_git_path "${${prefix}_${submodule_name}_base_git_path}")

    set(submodule_url "${submodule_base_git_path}")
    qt_ir_parse_git_url(
        URL "${submodule_url}"
        OUT_VAR_HAS_URL_SCHEME has_url_scheme
    )

    if(NOT has_url_scheme AND arg_BASE_URL)
        set(submodule_url "${arg_BASE_URL}${submodule_url}")
        qt_ir_normalize_git_url("${submodule_url}" submodule_url)
    endif()

    qt_ir_get_mirror(mirror_url)
    set(mirror "")
    if(NOT has_url_scheme AND mirror_url AND (should_clone OR arg_FETCH))
        set(mirror "${mirror_url}${submodule_base_git_path}")
        qt_ir_normalize_git_url("${mirror}" mirror)
    endif()

    set(mirror_or_original_url "${submodule_url}")
    if(mirror)
        # Only use the mirror if it can be reached.
        # Access a non-existing ref so no output is shown. It should still
        # succeed if the mirror is accessible.
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git ls-remote "${mirror}" "test/if/mirror/exists"
            WORKING_DIRECTORY "${working_directory}"
            NO_HANDLE_ERROR
            OUT_RESULT_VAR proc_result)
        if(NOT proc_result EQUAL 0)
            message("mirror [${mirror}] is not accessible; ${submodule_url} will be used")
            set(mirror "")
        else()
            set(mirror_or_original_url "${mirror}")
        endif()
    endif()

    set(submodule_branch "${${prefix}_${submodule_name}_branch}")

    qt_ir_is_git_progress_supported(is_git_progress_supported)
    qt_ir_get_option_value(quiet quiet)
    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)

    set(progress_args "")
    if(is_git_progress_supported AND NOT quiet AND NOT perl_identical_output_for_tests)
        set(progress_args --progress)
    endif()

    if(should_clone)
        if(arg_CHECKOUT_BRANCH)
            list(APPEND clone_args --branch "${submodule_branch}")
        else()
            list(APPEND clone_args --no-checkout)
        endif()
        list(APPEND clone_args ${progress_args})
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git clone ${clone_args} "${mirror_or_original_url}" "${submodule_path}"
            ERROR_MESSAGE "Failed to clone submodule '${submodule_name}'"
            WORKING_DIRECTORY "${working_directory}")
    endif()

    set(submodule_working_dir "${working_directory}/${submodule_path}")

    if(mirror)
        # This is only for the user's convenience - we make no use of it.
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git config "remote.mirror.url" "${mirror}"
            ERROR_MESSAGE "Failed to set git config remote.mirror.url to ${mirror}"
            WORKING_DIRECTORY "${submodule_working_dir}")
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git config "remote.mirror.fetch" "+refs/heads/*:refs/remotes/mirror/*"
            ERROR_MESSAGE "Failed to set git config remote.mirror.fetch"
            WORKING_DIRECTORY "${submodule_working_dir}")
    endif()

    if(NOT should_clone AND arg_FETCH)
        # If we didn't clone, fetch from the right location. We always update
        # the origin remote, so that submodule update --remote works.
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git config remote.origin.url "${mirror_or_original_url}"
            ERROR_MESSAGE "Failed to set remote origin url"
            WORKING_DIRECTORY "${submodule_working_dir}")
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git fetch origin ${progress_args}
            ERROR_MESSAGE "Failed to fetch origin"
            WORKING_DIRECTORY "${submodule_working_dir}")
    endif()

    if(NOT (should_clone OR arg_FETCH) OR mirror)
        # Leave the origin configured to the canonical URL. It's already correct
        # if we cloned/fetched without a mirror; otherwise it may be anything.
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git config remote.origin.url "${submodule_url}"
            ERROR_MESSAGE "Failed to set remote origin url"
            WORKING_DIRECTORY "${submodule_working_dir}")
endif()

    set(commit_template_dir "${working_directory}")
    qt_ir_setup_commit_template("${commit_template_dir}" "${submodule_working_dir}")

    if(NOT has_url_scheme)
        qt_ir_add_git_remotes("${submodule_base_git_path}" "${submodule_working_dir}")
    endif()

    qt_ir_handle_detach_alternates("${submodule_working_dir}")
endfunction()

# Get list of submodules that were previously initialized, by looking at the .git/config file.
function(qt_ir_get_already_initialized_submodules prefix
    out_var_already_initialized_submodules
    parent_repo_base_git_path
    working_directory
    )

    qt_ir_parse_git_config_file_contents("${prefix}"
        READ_GIT_CONFIG
        PARENT_REPO_BASE_GIT_PATH "${parent_repo_base_git_path}"
        WORKING_DIRECTORY "${working_directory}"
    )

    set(${out_var_already_initialized_submodules} "${${prefix}_submodules}" PARENT_SCOPE)
endfunction()

# If init-repository --force is called with a different subset, remove
# previously initialized submodules from the .git/config file.
# Also mark submodules as ignored if requested.
function(qt_ir_handle_submodule_removal_and_ignoring prefix
    included_submodules
    parent_repo_base_git_path
    working_directory
    )

    qt_ir_get_option_value(ignore-submodules ignore_submodules)

    qt_ir_get_already_initialized_submodules("${prefix}"
        already_initialized_submodules
        "${parent_repo_base_git_path}"
        "${working_directory}")

    foreach(submodule_name IN LISTS already_initialized_submodules)
        if(NOT submodule_name IN_LIST included_submodules)
            # If a submodule is not included in the list of submodules to be initialized,
            # and it was previously initialized, then remove it from the config.
            qt_ir_execute_process_and_log_and_handle_error(
                COMMAND_ARGS git config --remove-section "submodule.${submodule_name}"
                ERROR_MESSAGE "Failed to deinit submodule '${submodule_name}'"
                WORKING_DIRECTORY "${working_directory}")
            continue()
        endif()
        if(ignore_submodules)
            qt_ir_execute_process_and_log_and_handle_error(
                    COMMAND_ARGS git config "submodule.${submodule_name}.ignore" all
                    ERROR_MESSAGE "Failed to ignore submodule '${submodule_name}'"
                    WORKING_DIRECTORY "${working_directory}")
        endif()
    endforeach()
endfunction()

# Checks if the submodule is dirty (has uncommited changes).
function(qt_ir_check_if_dirty_submodule submodule_name working_directory out_is_dirty)
    set(submodule_path "${working_directory}/${${prefix}_${submodule_name}_path}")
    if(NOT EXISTS "${submodule_path}/.git")
        return()
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        FORCE_QUIET
        COMMAND_ARGS git status --porcelain --untracked=no --ignore-submodules=all
        WORKING_DIRECTORY "${submodule_path}"
        ERROR_MESSAGE "Failed to get dirty status for '${submodule_name}'"
        OUT_OUTPUT_VAR git_output)

    string(STRIP "${git_output}" git_output)
    string(REPLACE "\n" ";" git_lines "${git_output}")

    # After a git clone --no-checkout, git status reports all files as
    # staged for deletion, but we still want to update the submodule.
    # It's unlikely that a genuinely dirty index would have _only_ this
    # type of modifications, and it doesn't seem like a horribly big deal
    # to lose them anyway, so ignore them.
    # @sts = grep(!/^D  /, @sts);
    # Filter list that starts with the regex
    list(FILTER git_lines EXCLUDE REGEX "^D  ")

    if(git_lines)
        message(STATUS "${submodule_name} is dirty.")
        set(is_dirty TRUE)
    else()
        set(is_dirty FALSE)
    endif()

    set(${out_is_dirty} "${is_dirty}" PARENT_SCOPE)
endfunction()

# Checks if any submodules are dirty and exits early if any are.
function(qt_ir_handle_dirty_submodule submodules working_directory)
    set(any_is_dirty FALSE)
    foreach(submodule_name IN LISTS submodules)
        qt_ir_check_if_dirty_submodule("${submodule_name}" "${working_directory}" is_dirty)
        if(is_dirty)
            set(any_is_dirty TRUE)
        endif()
    endforeach()

    if(any_is_dirty)
        message(FATAL_ERROR "Dirty submodule(s) present; cannot proceed.")
    endif()
endfunction()

# If the branch option is set, checkout the branch specified in the .gitmodules file.
function(qt_ir_handle_branch_option prefix submodule_name working_directory)
    set(branch_name "${${prefix}_${submodule_name}_branch}")
    if(NOT branch_name)
        message(FATAL_ERROR "No branch defined for submodule '${submodule_name}'")
    endif()

    set(repo_dir "${working_directory}/${${prefix}_${submodule_name}_path}")
    qt_ir_execute_process_and_log_and_handle_error(
        FORCE_QUIET
        COMMAND_ARGS git rev-parse -q --verify ${branch_name}
        WORKING_DIRECTORY "${repo_dir}"
        NO_HANDLE_ERROR
        OUT_RESULT_VAR proc_result)

    # If the branch exists locally, check it out.
    # Otherwise check it out from origin and create a local branch.
    if(proc_result EQUAL 0)
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git checkout ${branch_name}
            WORKING_DIRECTORY "${repo_dir}"
            ERROR_MESSAGE
            "Failed to checkout branch '${branch_name}' in submodule '${submodule_name}'")
    else()
        qt_ir_execute_process_and_log_and_handle_error(
            COMMAND_ARGS git checkout -b ${branch_name} origin/${branch_name}
            WORKING_DIRECTORY "${repo_dir}"
            ERROR_MESSAGE
            "Failed to checkout branch '${branch_name}' in submodule '${submodule_name}'")
    endif()
endfunction()

# If the update option is set, update the submodules, without fetching.
function(qt_ir_handle_update_option will_checkout_branch working_directory)
    set(extra_args "")
    if(will_checkout_branch)
        list(APPEND extra_args --remote --rebase)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git submodule update --force --no-fetch ${extra_args}
        ERROR_MESSAGE "Failed to update submodule '${submodule_name}'"
        WORKING_DIRECTORY "${working_directory}")
endfunction()

# Looks for the 'default' and 'existing' keys, and replaces them with appropriate
# values, while making sure to prepend '-' to the values if the original key had it.
function(qt_ir_handle_dash_in_module_subset_expansion out_var
    module_subset already_initialized_submodules)

    set(expanded_module_subset "")
    foreach(submodule_name IN LISTS module_subset)
        set(has_dash FALSE)
        string(REGEX REPLACE "^(-)" "" submodule_name "${submodule_name}")
        if(CMAKE_MATCH_1)
            set(has_dash TRUE)
        endif()

        # Replace the default keyword in the input, with the the list of default submodules types,
        # which will be further replaced.
        if(submodule_name STREQUAL "default")
            set(replacement "preview;essential;addon;deprecated")
        # Replace the existing keyword, with the list of already initialized submodules
        # from a previous run.
        elseif(submodule_name STREQUAL "existing")
            set(replacement "${already_initialized_submodules}")

            if(has_dash)
                # We can't properly support this with the existing algorithm, because we will
                # then exclude it also after dependency resolution, and it can cause an empty list
                # of submodules in certain situations.
                message(FATAL_ERROR "Excluding existing submodules with '-existing' "
                    "is not supported, just don't include them.")
            endif()
        else()
            set(replacement "${submodule_name}")
        endif()

        # Prepend dash to all expanded values
        if(has_dash)
            list(TRANSFORM replacement PREPEND "-")
        endif()

        list(APPEND expanded_module_subset "${replacement}")
    endforeach()

    set(${out_var} "${expanded_module_subset}" PARENT_SCOPE)
endfunction()

# Processes the given module subset using values that were set by parsing the .gitmodules file.
#
# The module subset is a comma-separated list of module names, with an optional '-' at the start.
# If a - is present, the module (or special expanded keyword) is excluded from the subset.
# If the value is empty, the default subset is used on initial runs, or the previously
#   existing submodules are used on subsequent runs.
# If the value is "all", all known submodules are included.
# If the value is a status like 'addon' or 'essential', only submodules with that status are
#   included.
# If the value is 'existing', only submodules that were previously initialized are included.
#   This evaluates to an empty list for the first script run.
# If the value is a module name, only that module is included.
# The modules to exclude are also set separately, so they can be excluded even after dependency
# resolution which is done later.
function(qt_ir_process_module_subset_values prefix)
    set(options
        PREVIOUSLY_INITIALIZED
    )
    set(oneValueArgs
        OUT_VAR_INCLUDE
        OUT_VAR_EXCLUDE
    )
    set(multiValueArgs
        ALREADY_INITIALIZED_SUBMODULES
        EXTRA_IMPLICIT_SUBMODULES
        MODULE_SUBSET
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(REPLACE "," ";" module_subset "${arg_MODULE_SUBSET}")

    # If a module subset is not specified, either use the default list for the very first run,
    # or use the previously initialized submodules for a subsequent run.
    #
    # If the are no previously initialized submodules, and 'existing' is specified, default
    # to 'default'. This handles the case when someone runs git submodule deinit --all --force,
    # where git initrepository.initialized config key is still true, and then runs
    # configure -init-submodules. Without defaulting to default, we would end up with an empty
    # subset and configure would fail.
    if(NOT module_subset)
        if(arg_PREVIOUSLY_INITIALIZED)
            if(arg_ALREADY_INITIALIZED_SUBMODULES)
                set(module_subset "existing")
            else()
                message(DEBUG "No previously initialized submodules detected even though "
                        "'existing' was specified, defaulting to 'default'")
                set(module_subset "default")
            endif()
        else()
            set(module_subset "default")
        endif()
    endif()


    qt_ir_handle_dash_in_module_subset_expansion(
        expanded_module_subset "${module_subset}" "${arg_ALREADY_INITIALIZED_SUBMODULES}")

    set(include_modules "")
    set(exclude_modules "")

    if(arg_EXTRA_IMPLICIT_SUBMODULES)
        list(APPEND include_modules ${arg_EXTRA_IMPLICIT_SUBMODULES})
    endif()

    foreach(value IN LISTS expanded_module_subset ${prefix}_submodules_to_remove)
        # An '-' at the start means we should exclude those modules.
        string(REGEX REPLACE "^(-)" "" value "${value}")
        set(list_op "APPEND")
        if(CMAKE_MATCH_1)
            set(list_op "REMOVE_ITEM")
        endif()

        if(value STREQUAL "all")
            list(${list_op} include_modules "${${prefix}_submodules}")
            if("${list_op}" STREQUAL "REMOVE_ITEM")
                list(APPEND exclude_modules "${${prefix}_submodules}")
            endif()
        elseif(value IN_LIST ${prefix}_statuses)
            list(${list_op} include_modules "${${prefix}_status_${value}_submodules}")
            if("${list_op}" STREQUAL "REMOVE_ITEM")
                list(APPEND exclude_modules "${${prefix}_status_${value}_submodules}")
            endif()
        elseif(NOT "${${prefix}_${value}_path}" STREQUAL "")
            list(${list_op} include_modules "${value}")
            if("${list_op}" STREQUAL "REMOVE_ITEM")
                list(APPEND exclude_modules "${value}")
            endif()
        else()
            if(list_op STREQUAL "REMOVE_ITEM")
                message(WARNING "Excluding non-existent module: ${value}")
            else()
                message(FATAL_ERROR
                    "Invalid module subset specified, module name is non-existent: ${value}")
            endif()
        endif()
    endforeach()

    set(${arg_OUT_VAR_INCLUDE} "${include_modules}" PARENT_SCOPE)
    set(${arg_OUT_VAR_EXCLUDE} "${exclude_modules}" PARENT_SCOPE)
endfunction()

# Sort the modules and add dependencies if dependency resolving is enabled.
function(qt_ir_get_module_subset_including_deps prefix out_var initial_modules)
    qt_ir_get_option_value(resolve-deps resolve_deps)
    qt_ir_get_option_value(optional-deps include_optional_deps)
    if(resolve_deps)
        set(exclude_optional_deps "")
        if(NOT include_optional_deps)
            set(exclude_optional_deps EXCLUDE_OPTIONAL_DEPS)
        endif()

        qt_internal_sort_module_dependencies("${initial_modules}" out_repos
            ${exclude_optional_deps}
            PARSE_GITMODULES
            GITMODULES_PREFIX_VAR "${prefix}"
        )
    else()
        set(out_repos "${initial_modules}")
    endif()

    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)
    if(NOT perl_identical_output_for_tests)
        message(DEBUG "repos that will be initialized after dependency handling: ${out_repos}")
    endif()

    set(${out_var} "${out_repos}" PARENT_SCOPE)
endfunction()

# Check whether init-repository has been run before, perl style.
# We assume that if the submodule qtbase has been initialized, then init-repository has been run.
function(qt_ir_check_if_already_initialized_perl_style out_var_is_initialized working_directory)
    set(cmd git config --get submodule.qtbase.url)

    set(extra_args "")
    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)
    if(perl_identical_output_for_tests)
        list(APPEND extra_args FORCE_QUIET)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS ${cmd}
        OUT_RESULT_VAR git_result
        OUT_OUTPUT_VAR git_output
        OUT_ERROR_VAR git_error
        ${extra_args}
        NO_HANDLE_ERROR
        WORKING_DIRECTORY "${working_directory}")

    if(git_result EQUAL 1 AND NOT git_output)
        set(is_initialized FALSE)
    elseif(git_result EQUAL 0 AND git_output)
        set(is_initialized TRUE)
    else()
        message(FATAL_ERROR "Failed to get result of ${cmd}: ${git_output}")
    endif()

    set(${out_var_is_initialized} "${is_initialized}" PARENT_SCOPE)
endfunction()

# Check whether init-repository has been run before, cmake style.
# Check for the presence of the initrepository.initialized git config key.
function(qt_ir_check_if_already_initialized_cmake_style out_var_is_initialized working_directory)
    set(options
        FORCE_QUIET
    )
    set(oneValueArgs "")
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(cmd git config --get initrepository.initialized)

    set(extra_args "")
    if(arg_FORCE_QUIET)
        list(APPEND extra_args FORCE_QUIET)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS ${cmd}
        OUT_RESULT_VAR git_result
        OUT_OUTPUT_VAR git_output
        OUT_ERROR_VAR git_error
        ${extra_args}
        NO_HANDLE_ERROR
        WORKING_DIRECTORY "${working_directory}")

    if(git_result EQUAL 1 AND NOT git_output)
        set(is_initialized FALSE)
    elseif(git_result EQUAL 0 AND git_output)
        set(is_initialized TRUE)
    else()
        message(FATAL_ERROR "Failed to get result of ${cmd}: ${git_output}")
    endif()

    set(${out_var_is_initialized} "${is_initialized}" PARENT_SCOPE)
endfunction()

# Check whether init-repository has been run before.
# The CMake and perl script do it differently, choose which way to do it based
# on the active options.
function(qt_ir_check_if_already_initialized out_var_is_initialized working_directory)
    qt_ir_get_option_value(perl-init-check perl_init_check)
    if(perl_init_check)
        qt_ir_check_if_already_initialized_perl_style(is_initialized "${working_directory}")
    else()
        qt_ir_check_if_already_initialized_cmake_style(is_initialized "${working_directory}")
    endif()

    set(${out_var_is_initialized} "${is_initialized}" PARENT_SCOPE)
endfunction()

# Marks the repository as initialized.
# The perl script used to determine this by checking whether the qtbase submodule was initialized.
# In the CMake script, we instead opt to set an explicit marker in the repository.
function(qt_ir_set_is_initialized working_directory)
    # If emulating perl style initialization check, don't set the marker and exit early.
    qt_ir_get_option_value(perl-init-check perl_init_check)
    if(perl_init_check)
        return()
    endif()

    set(cmd git config initrepository.initialized true)

    set(extra_args "")
    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)
    if(perl_identical_output_for_tests)
        list(APPEND extra_args FORCE_QUIET)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS ${cmd}
        ERROR_MESSAGE "Failed to mark repository as initialized"
        ${extra_args}
        WORKING_DIRECTORY "${working_directory}")
endfunction()

# If the repository has already been initialized, exit early.
function(qt_ir_handle_if_already_initialized out_var_should_exit working_directory)
    set(should_exit FALSE)

    qt_ir_check_if_already_initialized(is_initialized "${working_directory}")
    qt_ir_get_option_value(force force)
    qt_ir_get_option_value(quiet quiet)
    qt_ir_is_called_from_configure(is_called_from_configure)

    if(is_initialized)
        if(NOT force)
            set(should_exit TRUE)
            if(NOT quiet AND NOT is_called_from_configure)
                message(
                    "Will not reinitialize already initialized repository (use -f to force)!")
            endif()
        endif()
    endif()

    set(${out_var_should_exit} ${should_exit} PARENT_SCOPE)
endfunction()

# Parses git remote.origin.url and extracts the base url and the repository name.
#
# base_url example: git://code.qt.io/qt
# repo name example: qt5 or tqtc-qt5
function(qt_ir_get_qt5_repo_name_and_base_url)
    set(options "")
    set(oneValueArgs
        OUT_VAR_QT5_REPO_NAME
        OUT_VAR_BASE_URL
        WORKING_DIRECTORY
    )
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "qt_ir_get_qt5_repo_name_and_base_url: No working directory specified")
    endif()
    set(working_directory "${arg_WORKING_DIRECTORY}")

    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)

    set(extra_args "")
    if(perl_identical_output_for_tests)
        set(extra_args FORCE_QUIET)
    endif()

    qt_ir_execute_process_and_log_and_handle_error(
        COMMAND_ARGS git config remote.origin.url ${extra_args}
        ERROR_MESSAGE "No origin remote found for qt5 repository"
        OUT_OUTPUT_VAR git_output
        WORKING_DIRECTORY "${working_directory}")

    string(STRIP "${git_output}" git_output)

    # Remove the .git at the end, with an optional slash
    string(REGEX REPLACE ".git/?$" "" qt5_repo_name "${git_output}")

    # Remove the tqtc- prefix, if it exists, and the qt5 suffix and that will be the base_url
    # The qt5_repo_name is qt5 or tqtc-qt5.
    string(REGEX REPLACE "((tqtc-)?qt5)$" "" base_url "${qt5_repo_name}")
    set(qt5_repo_name "${CMAKE_MATCH_1}")

    if(NOT qt5_repo_name)
        set(qt5_repo_name "qt5")
    endif()

    if(NOT base_url)
        message(FATAL_ERROR "Failed to parse base url from origin remote: ${git_output}")
    endif()

    set(${arg_OUT_VAR_QT5_REPO_NAME} "${qt5_repo_name}" PARENT_SCOPE)
    set(${arg_OUT_VAR_BASE_URL} "${base_url}" PARENT_SCOPE)
endfunction()

# Creates a symlink or a forwarding script to the target path.
# Use for setting up git hooks.
function(qt_ir_ensure_link source_path target_path)
    qt_ir_get_option_value(force-hooks force_hooks)
    if(EXISTS "${target_path}" AND NOT force_hooks)
        return()
    endif()

    # In case we have a dead symlink or pre-existing hook
    file(REMOVE "${target_path}")

    qt_ir_get_option_value(quiet quiet)
    if(NOT quiet)
        message("Aliasing ${source_path}\n      as ${target_path} ...")
    endif()

    if(NOT CMAKE_HOST_WIN32)
        file(CREATE_LINK "${source_path}" "${target_path}" RESULT result SYMBOLIC)
        # Don't continue upon success. If symlinking failed, fallthrough to creating
        # a forwarding script.
        if(result EQUAL 0)
            return()
        endif()
    endif()

    # Windows doesn't do (proper) symlinks. As the post_commit script needs
    # them to locate itself, we write a forwarding script instead.

    # Make the path palatable for MSYS.
    string(REGEX REPLACE "^(.):/" "/\\1/" source_path "${source_path}")

    set(contents "#!/bin/sh\nexec ${source_path} \"$@\"\n")
    file(WRITE "${target_path}" "${contents}")
endfunction()

# Installs the git hooks from the qtrepotools module.
function(qt_ir_install_git_hooks)
    set(options "")
    set(oneValueArgs
        PARENT_REPO_BASE_GIT_PATH
        TOP_LEVEL_SRC_PATH
        WORKING_DIRECTORY
    )
    set(multiValueArgs "")
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT arg_WORKING_DIRECTORY)
        message(FATAL_ERROR "qt_ir_install_git_hooks: No working directory specified")
    endif()
    set(working_directory "${arg_WORKING_DIRECTORY}")

    if(NOT arg_PARENT_REPO_BASE_GIT_PATH)
        message(FATAL_ERROR "qt_ir_install_git_hooks: No PARENT_REPO_BASE_GIT_PATH specified")
    endif()
    set(parent_repo_base_git_path "${arg_PARENT_REPO_BASE_GIT_PATH}")

    if(NOT arg_TOP_LEVEL_SRC_PATH)
        message(FATAL_ERROR "qt_ir_install_git_hooks: No TOP_LEVEL_SRC_PATH specified")
    endif()
    set(top_level_src_path "${arg_TOP_LEVEL_SRC_PATH}")

    set(hooks_dir "${top_level_src_path}/qtrepotools/git-hooks")
    if(NOT EXISTS "${hooks_dir}")
        message("Warning: cannot find Git hooks, qtrepotools module might be absent")
        return()
    endif()

    set(prefix ir_hooks)
    qt_ir_parse_git_config_file_contents("${prefix}"
        READ_GIT_CONFIG_LOCAL
        PARENT_REPO_BASE_GIT_PATH "${parent_repo_base_git_path}"
        WORKING_DIRECTORY "${working_directory}"
    )

    foreach(submodule_name IN LISTS ${prefix}_submodules)
        set(submodule_git_dir "${working_directory}/${submodule_name}/.git")
        if(NOT IS_DIRECTORY "${submodule_git_dir}")
            # Get first line
            file(STRINGS "${submodule_git_dir}" submodule_git_dir_contents LIMIT_COUNT 1)

            # Remove the gitdir: prefix
            string(REGEX REPLACE "^(gitdir: )" "" submodule_git_dir
                "${submodule_git_dir_contents}")
            if("${CMAKE_MATCH_1}" STREQUAL "")
                message(FATAL_ERROR "Malformed .git file ${submodule_git_dir}")
            endif()

            # Make it an absolute path, because gitdir: is usually relative to the submodule
            get_filename_component(submodule_git_dir "${submodule_git_dir}"
                ABSOLUTE BASE_DIR "${working_directory}/${submodule_name}")

            # Untested
            set(common_dir "${submodule_git_dir}/commondir")
            if(EXISTS "${common_dir}")
                file(STRINGS "${common_dir}" common_dir_contents LIMIT_COUNT 1)
                string(STRIP "${common_dir_contents}" common_dir_path)
                set(submodule_git_dir "${submodule_git_dir}/${common_dir_path}")
                get_filename_component(submodule_git_dir "${submodule_git_dir}" ABSOLUTE)
            endif()
        endif()
        qt_ir_ensure_link("${hooks_dir}/gerrit_commit_msg_hook"
            "${submodule_git_dir}/hooks/commit-msg")
        qt_ir_ensure_link("${hooks_dir}/git_post_commit_hook"
            "${submodule_git_dir}/hooks/post-commit")
        qt_ir_ensure_link("${hooks_dir}/clang-format-pre-commit"
            "${submodule_git_dir}/hooks/pre-commit")
    endforeach()
endfunction()

# Saves the list of top-level submodules that should be included and excluded.
# Will be used to pass these values to the top-level configure script.
function(qt_ir_set_top_level_submodules included_submodules excluded_submodules)
    set_property(GLOBAL PROPERTY _qt_ir_top_level_included_submodules "${included_submodules}")
    set_property(GLOBAL PROPERTY _qt_ir_top_level_excluded_submodules "${excluded_submodules}")
endfunction()

# Gets the list of top-level submodules that should be included and excluded.
function(qt_ir_get_top_level_submodules out_included_submodules out_excluded_submodules)
    get_property(included GLOBAL PROPERTY _qt_ir_top_level_included_submodules)
    get_property(excluded GLOBAL PROPERTY _qt_ir_top_level_excluded_submodules)

    set(${out_included_submodules} "${included}" PARENT_SCOPE)
    set(${out_excluded_submodules} "${excluded}" PARENT_SCOPE)
endfunction()

# Parses the .gitmodules file and proceses the submodules based on the module-subset option
# or the given SUBMODULES argument.
# Also adds dependencies if requested.
#
# This is a macro because we want the variables set by
# qt_ir_parse_gitmodules_file_contents to be available in the calling scope, because it's
# essentially setting a dictionarty, and we don't want to propagate all the variables manually.
macro(qt_ir_get_submodules prefix out_var_submodules)
    set(options
        PREVIOUSLY_INITIALIZED
        PROCESS_SUBMODULES_FROM_COMMAND_LINE
    )
    set(oneValueArgs
        PARENT_REPO_BASE_GIT_PATH
        WORKING_DIRECTORY
    )
    set(multiValueArgs
        ALREADY_INITIALIZED_SUBMODULES
        SUBMODULES
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    qt_ir_get_working_directory_from_arg(working_directory)

    # Parse the .gitmodules content here, so the parsed data is available downstream
    # in other functions and recursive calls of the same function.
    qt_ir_parse_git_config_file_contents("${prefix}"
        READ_GITMODULES
        PARENT_REPO_BASE_GIT_PATH "${arg_PARENT_REPO_BASE_GIT_PATH}"
        WORKING_DIRECTORY "${working_directory}"
    )

    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)
    set(extra_implict_submodules "")

    # Get which modules should be initialized, based on the module-subset option.
    if(arg_PROCESS_SUBMODULES_FROM_COMMAND_LINE)
        qt_ir_get_option_value(module-subset initial_module_subset)

        # Implicitly add qtrepotools, so we can install git hooks and don't get the
        # missing qtrepotools warning.
        if(NOT perl_identical_output_for_tests)
            list(APPEND extra_implict_submodules "qtrepotools")
            qt_ir_is_verbose(verbose)
            if(verbose)
                message("Implicitly adding qtrepotools to the list of submodules "
                        "to initialize for access to git commit hooks, etc. "
                        "(use --module-subset=<values>,-qtrepotools to exclude it)")
            endif()
        endif()

        if(NOT perl_identical_output_for_tests)
            message(DEBUG "module-subset from command line: ${initial_module_subset}")
        endif()
    elseif(arg_SUBMODULES)
        set(initial_module_subset "${arg_SUBMODULES}")
        if(NOT perl_identical_output_for_tests)
            message(DEBUG "module-subset from args: ${initial_module_subset}")
        endif()
    else()
        message(FATAL_ERROR "No submodules specified")
    endif()

    qt_ir_get_cmake_flag(PREVIOUSLY_INITIALIZED previously_initialized_opt)
    qt_ir_process_module_subset_values("${prefix}"
        ${previously_initialized_opt}
        ${perl_identical_output_opt}
        ALREADY_INITIALIZED_SUBMODULES ${arg_ALREADY_INITIALIZED_SUBMODULES}
        EXTRA_IMPLICIT_SUBMODULES ${extra_implict_submodules}
        MODULE_SUBSET "${initial_module_subset}"
        OUT_VAR_INCLUDE processed_module_subset
        OUT_VAR_EXCLUDE modules_to_exclude
    )
    if(NOT perl_identical_output_for_tests)
        message(DEBUG "Processed module subset: ${processed_module_subset}")
    endif()

    # We only resolve dependencies for the top-level call, not for recursive calls.
    if(arg_PROCESS_SUBMODULES_FROM_COMMAND_LINE)
        # Resolve which submodules should be initialized, including dependencies.
        qt_ir_get_module_subset_including_deps("${prefix}"
            submodules_with_deps "${processed_module_subset}")

        # Then remove any explicitly specified submodules.
        set(submodules_with_deps_and_excluded "${submodules_with_deps}")
        if(modules_to_exclude)
            list(REMOVE_ITEM submodules_with_deps_and_excluded ${modules_to_exclude})
        endif()

        if(NOT perl_identical_output_for_tests AND modules_to_exclude)
            message(DEBUG "Repos that will be excluded after dependency handling: ${modules_to_exclude}")
        endif()

        set(submodules "${submodules_with_deps_and_excluded}")
        qt_ir_set_top_level_submodules("${submodules}" "${modules_to_exclude}")
    else()
        set(submodules "${processed_module_subset}")
    endif()

    # Remove duplicates
    set(submodules_maybe_duplicates "${submodules}")
    list(REMOVE_DUPLICATES submodules)
    if(NOT perl_identical_output_for_tests AND NOT submodules STREQUAL submodules_maybe_duplicates)
            message(DEBUG "Removed duplicates from submodules, final list: ${submodules}")
    endif()

    set(${out_var_submodules} "${submodules}" PARENT_SCOPE)
endmacro()

# Recursively initialize submodules starting from the given current working directory.
# This is the equivalent of the perl script's git_clone_all_submodules function.
function(qt_ir_handle_init_submodules prefix)
    set(options
        CHECKOUT_BRANCH
        PREVIOUSLY_INITIALIZED
        PROCESS_SUBMODULES_FROM_COMMAND_LINE
    )
    set(oneValueArgs
        ALTERNATES
        BASE_URL
        PARENT_REPO_BASE_GIT_PATH
        WORKING_DIRECTORY
    )
    set(multiValueArgs
        ALREADY_INITIALIZED_SUBMODULES
        SUBMODULES
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    qt_ir_get_working_directory_from_arg(working_directory)

    # Get the submodules that should be initialized.
    qt_ir_get_cmake_flag(PROCESS_SUBMODULES_FROM_COMMAND_LINE
                         process_submodules_from_command_line_opt)
    qt_ir_get_cmake_flag(PREVIOUSLY_INITIALIZED
                         previously_initialized_opt)
    qt_ir_get_submodules(${prefix} submodules
        ${process_submodules_from_command_line_opt}
        ${previously_initialized_opt}
        ALREADY_INITIALIZED_SUBMODULES ${arg_ALREADY_INITIALIZED_SUBMODULES}
        PARENT_REPO_BASE_GIT_PATH "${arg_PARENT_REPO_BASE_GIT_PATH}"
        SUBMODULES "${arg_SUBMODULES}"
        WORKING_DIRECTORY "${working_directory}"
    )

    qt_ir_get_option_value(perl-identical-output perl_identical_output_for_tests)
    if(NOT submodules AND NOT perl_identical_output_for_tests)
        message("No submodules were given to initialize or they were all excluded.")
        return()
    endif()

    # Initialize the submodules, but don't clone them yet.
    qt_ir_run_git_submodule_init("${submodules}" "${working_directory}")

    # Deinit submodules that are not in the list of submodules to be initialized.
    qt_ir_handle_submodule_removal_and_ignoring("${prefix}"
        "${submodules}" "${arg_PARENT_REPO_BASE_GIT_PATH}" "${working_directory}")

    # Check for dirty submodules.
    qt_ir_handle_dirty_submodule("${submodules}" "${working_directory}")

    qt_ir_get_cmake_flag(CHECKOUT_BRANCH branch_flag)
    qt_ir_get_option_as_cmake_flag_option(fetch "FETCH" fetch_flag)

    # Manually clone each submodule if it was not previously cloned, so we can easily
    # use reference (alternates) repos, mirrors, etc.
    # If already cloned, just fetch new data.
    #
    # Note that manually cloning the submodules, as opposed to running git submodule update,
    # places the .git directories inside the submodule directories, but latest git versions
    # expect it in $super_repo/.git/modules.
    # When de-initializing submodules manually, git will absorb the .git directories into the super
    # repo.
    # In case if the super repo already has a copy of the submodule .git dir, git will fail
    # to absorb the .git dir and error out. In that case the already existing .git dir needs to be
    # removed manually, there is no git command to do it afaik.
    foreach(submodule_name IN LISTS submodules)
        qt_ir_clone_one_submodule(${submodule_name}
            ALTERNATES ${arg_ALTERNATES}
            BASE_URL ${arg_BASE_URL}
            WORKING_DIRECTORY "${working_directory}"
            ${branch_flag}
            ${fetch_flag}
        )
    endforeach()

    # Checkout branches instead of the default detached HEAD.
    if(branch_flag)
        foreach(submodule_name IN LISTS submodules)
            qt_ir_handle_branch_option("${prefix}" ${submodule_name} "${working_directory}")
        endforeach()
    endif()

    qt_ir_get_option_value(update will_update)
    if(will_update)

        # Update the checked out refs without fetching.
        qt_ir_handle_update_option("${branch_flag}" "${working_directory}")

        # Recursively initialize submodules of submodules.
        foreach(submodule_name IN LISTS submodules)
            set(submodule_path "${${prefix}_${submodule_name}_path}")
            set(submodule_gitmodules_path "${working_directory}/${submodule_path}/.gitmodules")

            if(EXISTS "${submodule_gitmodules_path}")
                set(alternates_option "")
                if(arg_ALTERNATES)
                    set(alternates_option ALTERNATES "${arg_ALTERNATES}/${submodule_name}")
                endif()

                set(submodule_base_git_path "${${prefix}_${submodule_name}_base_git_path}")

                qt_ir_handle_init_submodules(
                    # Use a different prefix to store new gitmodules data
                    ir_sub_${submodule_name}

                    # Check out all submodules recursively
                    SUBMODULES "all"

                    BASE_URL "${base_url}"
                    PARENT_REPO_BASE_GIT_PATH "${submodule_base_git_path}"
                    WORKING_DIRECTORY "${working_directory}/${submodule_name}"

                    # The CHECKOUT_BRANCH option is not propagated on purpose
                    ${alternates_option}
                )
            endif()
        endforeach()
    endif()
endfunction()
