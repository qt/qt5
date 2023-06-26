HOW TO BUILD Qt 6
=================


Synopsis
========

System requirements
-------------------

* C++ compiler supporting the C++17 standard
* CMake
* Ninja
* Python 3

For more details, see also https://doc.qt.io/qt-6/build-sources.html

Linux, Mac:
-----------

```
cd <path>/<source_package>
./configure -prefix $PWD/qtbase
cmake --build .
```

Windows:
--------

1. Open a command prompt.
2. Ensure that the following tools can be found in the path:
 * Supported compiler (Visual Studio 2019 or later, or MinGW-builds gcc 8.1 or later)
 * Python 3 ([https://www.python.org/downloads/windows/] or from Microsoft Store)

```
cd <path>\<source_package>
configure -prefix %CD%\qtbase
cmake --build .
```

More details follow.


Build!
======

Qt is built with CMake, and a typical
`configure && cmake --build .` build process is used.

If Ninja is installed, it is automatically chosen as CMake generator.

Some relevant configure options (see configure -help):

* `-release` Compile and link Qt with debugging turned off.
* `-debug` Compile and link Qt with debugging turned on.

Example for a release build:

```
./configure -prefix $PWD/qtbase
cmake --build .
```

Example for a developer build:
(enables more autotests, builds debug version of libraries, ...)

```
./configure -developer-build
cmake --build .
```

 See output of `./configure -help` for documentation on various options to
 configure.

 The above examples will build whatever Qt modules have been enabled
 by default in the build system.

 It is possible to build selected repositories with their dependencies by doing
 a `ninja <repo-name>/all`.  For example, to build only qtdeclarative,
 and the modules it depends on:

```
./configure
ninja qtdeclarative/all
```

This can save a lot of time if you are only interested in a subset of Qt.


Hints
=====

The submodule repository `qtrepotools` contains useful scripts for
developers and release engineers. Consider adding qtrepotools/bin
to your `PATH` environment variable to access them.


Building Qt from git
====================

See http://wiki.qt.io/Building_Qt_6_from_Git and README.git
for more information.
See http://wiki.qt.io/Qt_6 for the reference platforms.


Documentation
=============

After configuring and compiling Qt, building the documentation is possible by running

```
cmake --build . --target docs
```

After having built the documentation, you need to install it with the following
command:

```
cmake --build . --target install_docs
```

The documentation is installed in the path specified with the
configure argument `-docdir`.

Information about Qt's documentation is located in qtbase/doc/README

Note: Building the documentation is only tested on desktop platforms.
