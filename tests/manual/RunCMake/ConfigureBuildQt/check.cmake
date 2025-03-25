# This file is include()d by run_cmake right after it calls execute_process.
# The msg var is set to a non-empty value when the was an error of
# some kind. Record failure with a separate variable in the parent scope,
# so we can FATAL_ERROR at the end.
if(NOT "${msg}" STREQUAL "")
    set(should_error_out TRUE PARENT_SCOPE)
else()
    set(should_error_out FALSE PARENT_SCOPE)
endif()
