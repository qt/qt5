# This script is to be called (ideally from a git-sync-to alias script):
#     cmake -DSYNC_TO_MODULE="$1" -DSYNC_TO_BRANCH="$2" -P cmake/QtSynchronizeRepo.cmake

cmake_policy(VERSION 3.16)
include(cmake/QtTopLevelHelpers.cmake)

qt_internal_sync_to(${SYNC_TO_MODULE} ${SYNC_TO_BRANCH})
