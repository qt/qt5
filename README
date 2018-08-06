HOW TO BUILD QT5
================


 Synopsis
 ========

   System requirements
   ------------------

    - Perl 5.8 or later
    - Python 2.7 or later
    - C++ compiler supporting the C++11 standard

     For other platform specific requirements,
     please see section "Setting up your machine" on:
     http://wiki.qt.io/Get_The_Source

   Licensing:
   ----------

    Opensource users:

        <license>        = -opensource

    Commercial users:

        <license>        = -commercial

   Linux, Mac:
   -----------

     cd <path>/<source_package>
     ./configure -prefix $PWD/qtbase <license> -nomake tests
     make -j 4

   Windows:
   --------

     Open a command prompt.
     Ensure that the following tools can be found in the path:
     * Supported compiler (Visual Studio 2012 or later,
        MinGW-builds gcc 4.9 or later)
     * Perl version 5.12 or later   [http://www.activestate.com/activeperl/]
     * Python version 2.7 or later  [http://www.activestate.com/activepython/]
     * Ruby version 1.9.3 or later  [http://rubyinstaller.org/]

     cd <path>\<source_package>
     configure -prefix %CD%\qtbase <license> -nomake tests
     nmake // jom // mingw32-make

     To accelerate the bootstrap of qmake with MSVC, it may be useful to pass
     "-make-tool jom" on the configure command line. If you do not use jom,
     adding "/MP" to the CL environment variable is a good idea.

 More details follow.

 Build!
 ======

 A typical `configure; make' build process is used.

 Some relevant configure options (see configure -help):

 -release              Compile and link Qt with debugging turned off.
 -debug                Compile and link Qt with debugging turned on.
 -nomake tests         Disable building of tests to speed up compilation
 -nomake examples      Disable building of examples to speed up compilation
 -confirm-license      Automatically acknowledge the LGPL 2.1 license.

 Example for a release build:
 (adjust the `-jN' parameter as appropriate for your system)

   ./configure -prefix $PWD/qtbase <license>
   make -j4

 Example for a developer build:
 (enables more autotests, builds debug version of libraries, ...)

   ./configure -developer-build <license>
   make -j4

 See output of `./configure -help' for documentation on various options to
 configure.

 The above examples will build whatever Qt5 modules have been enabled by
 default in the build system.

 It is possible to build selected modules with their dependencies by doing
 a `make module-<foo>'.  For example, to build only qtdeclarative,
 and the modules it depends on:

   ./configure -prefix $PWD/qtbase <license>
   make -j4 module-qtdeclarative

 This can save a lot of time if you are only interested in a subset of Qt5.


 Hints
 =====

 The submodule repository qtrepotools contains useful scripts for
 developers and release engineers. Consider adding qtrepotools/bin
 to your PATH environment variable to access them.

 The qt5_tool in qtrepotools has some more features which may be of interest.
 Try `qt5_tool --help'.


 Building Qt5 from git
 =====================
 See http://wiki.qt.io/Building_Qt_5_from_Git and README.git
 for more information.
 See http://wiki.qt.io/Qt_5 for the reference platforms.


 Documentation
 =============

 After configuring and compiling Qt, building the documentation is possible by running
 "make docs".

 After having built the documentation, you need to install it with the following
 command:

    make install_docs

 The documentation is installed in the path set to $QT_INSTALL_DOCS.
 Running "qmake -query" will list the value of QT_INSTALL_DOCS.

 Information about Qt 5's documentation is located in qtbase/doc/README
 or in the following page: http://wiki.qt.io/Qt5DocumentationProject

 Note: Building the documentation is only tested on desktop platforms.
