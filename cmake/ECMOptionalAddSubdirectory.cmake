#.rst:
# ECMOptionalAddSubdirectory
# --------------------------
#
# Make subdirectories optional.
#
# ::
#
#   ecm_optional_add_subdirectory(<dir>)
#
# This behaves like add_subdirectory(), except that it does not complain if the
# directory does not exist.  Additionally, if the directory does exist, it
# creates an option to allow the user to skip it. The option will be named
# BUILD_<dir>.
#
# This is useful for "meta-projects" that combine several mostly-independent
# sub-projects.
#
# If the CMake variable DISABLE_ALL_OPTIONAL_SUBDIRECTORIES is set to TRUE for
# the first CMake run on the project, all optional subdirectories will be
# disabled by default (but can of course be enabled via the respective options).
# For example, the following will disable all optional subdirectories except the
# one named "foo":
#
# .. code-block:: sh
#
#   cmake -DDISABLE_ALL_OPTIONAL_SUBDIRECTORIES=TRUE -DBUILD_foo=TRUE myproject
#
# Since pre-1.0.0.

#=============================================================================
# Copyright 2007 Alexander Neundorf <neundorf@kde.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function(ECM_OPTIONAL_ADD_SUBDIRECTORY _dir)
  get_filename_component(_fullPath ${_dir} ABSOLUTE)
  if(EXISTS ${_fullPath}/CMakeLists.txt)
    if(DISABLE_ALL_OPTIONAL_SUBDIRECTORIES)
      set(_DEFAULT_OPTION_VALUE FALSE)
    else()
      set(_DEFAULT_OPTION_VALUE TRUE)
    endif()
    if(DISABLE_ALL_OPTIONAL_SUBDIRS  AND NOT DEFINED  BUILD_${_dir})
      set(_DEFAULT_OPTION_VALUE FALSE)
    endif()
    option(BUILD_${_dir} "Build directory ${_dir}" ${_DEFAULT_OPTION_VALUE})
    if(BUILD_${_dir})
      add_subdirectory(${_dir})
    endif()
  endif()
endfunction()
