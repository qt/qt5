# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# This script is to be called (ideally from a git-sync-to alias script):
#     cmake -DSYNC_TO_MODULE="$1" -DSYNC_TO_BRANCH="$2" -P cmake/QtSynchronizeRepo.cmake

# Or as follows (ideally from a git-qt-foreach alias script):
#     cmake -DQT_FOREACH=TRUE "-DARGS=$*" -P cmake/QtSynchronizeRepo.cmake
#
# The script can take additional options.
#
# SYNC_REF_SPEC - an alias for SYNC_TO_BRANCH, can be a tag, branch or commit sha1.
#
# REMOTE_NAME - remote name to use for fetching, default is origin.
#
# GIT_DEPTH - corresponds to git's --depth option, will be passed to git clone and git submodule
# update --init operations.
#
# SHOW_PROGRESS - passes --progress to git submodule update operations
#
# FORCE_CHECKOUT - passes --force to git checkout, discarding local changes in the synchronized
# repos.
#
# VERBOSE - enables more verbose output
#
# The script also takes the following environment variables:
#
# QT_TL_SUBMODULE_UPDATE_FLAGS - additional flags to pass to git submodule update calls.
#
# To run the script in full debug mode use:
# cmake -DSYNC_TO_MODULE="$1" -DSYNC_TO_BRANCH="$2" -DSHOW_PROGRESS=1 -DVERBOSE=1
#       -P cmake/QtSynchronizeRepo.cmake --log-level=DEBUG --trace-redirect=log.txt --trace-expand

cmake_policy(VERSION 3.16)
include("${CMAKE_CURRENT_LIST_DIR}/QtTopLevelHelpers.cmake")
if(QT_FOREACH)
    qt_internal_foreach_repo_run(ARGS ${ARGS})
else()
    set(args "")

    if(SYNC_REF_SPEC)
        set(ref_spec "${SYNC_REF_SPEC}")
    elseif(SYNC_TO_BRANCH)
        set(ref_spec "${SYNC_TO_BRANCH}")
    endif()

    if(REMOTE_NAME)
        list(APPEND args REMOTE_NAME "${REMOTE_NAME}")
    endif()

    if(GIT_DEPTH)
        list(APPEND args GIT_DEPTH "${GIT_DEPTH}")
    endif()

    if(SHOW_PROGRESS)
        list(APPEND args SHOW_PROGRESS)
    endif()

    if(FORCE_CHECKOUT)
        list(APPEND args FORCE_CHECKOUT)
    endif()

    if(VERBOSE)
        list(APPEND args VERBOSE)
    endif()

    qt_internal_sync_to(${SYNC_TO_MODULE}
        SYNC_REF ${ref_spec}
        ${args}
    )
endif()
