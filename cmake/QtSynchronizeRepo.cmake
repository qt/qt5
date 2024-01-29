# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

# This script is to be called (ideally from a git-sync-to alias script):
#     cmake -DSYNC_TO_MODULE="$1" -DSYNC_TO_BRANCH="$2" -P cmake/QtSynchronizeRepo.cmake
# Or as follows (ideally from a git-qt-foreach alias script):
#     cmake -DQT_FOREACH=TRUE "-DARGS=$*" -P cmake/QtSynchronizeRepo.cmake

cmake_policy(VERSION 3.16)
include(cmake/QtTopLevelHelpers.cmake)
if(QT_FOREACH)
    qt_internal_foreach_repo_run(ARGS ${ARGS})
else()
    qt_internal_sync_to(${SYNC_TO_MODULE} ${SYNC_TO_BRANCH})
endif()
