TEMPLATE      = subdirs

module_qtbase.subdir = $$IN_PWD/qtbase
module_qtbase.target = module-qtbase

module_qtsvg.subdir = $$IN_PWD/qtsvg
module_qtsvg.target = module-qtsvg
module_qtsvg.depends = module_qtbase

module_phonon.subdir = $$IN_PWD/qtphonon
module_phonon.target = module-phonon
module_phonon.depends = module_qtbase

module_qtmultimedia.subdir = $$IN_PWD/qtmultimedia
module_qtmultimedia.target = module-qtmultimedia
module_qtmultimedia.depends = module_qtbase

module_qtxmlpatterns.subdir = $$IN_PWD/qtxmlpatterns
module_qtxmlpatterns.target = module-qtxmlpatterns
module_qtxmlpatterns.depends = module_qtbase

module_qtscript.subdir = $$IN_PWD/qtscript
module_qtscript.target = module-qtscript
module_qtscript.depends = module_qtbase

module_qtdeclarative.subdir = $$IN_PWD/qtdeclarative
module_qtdeclarative.target = module-qtdeclarative
module_qtdeclarative.depends = module_qtbase module_qtscript module_qtsvg module_qtxmlpatterns

module_qt3support.subdir = $$IN_PWD/qt3support
module_qt3support.target = module-qt3support
module_qt3support.depends = module_qtbase

module_qtwebkit.file = qtwebkit.pri
module_qtwebkit.makefile = Makefile.qtwebkit
module_qtwebkit.depends = module_qtbase module_qtscript module_qtdeclarative module_phonon
# The qtwebkit subdir does not follow the "module-*" scheme, so make our own target that does.
module_qtwebkit_target.target = module-qtwebkit
module_qtwebkit_target.commands =
module_qtwebkit_target.depends = sub-qtwebkit-pri
QMAKE_EXTRA_TARGETS += module_qtwebkit_target

qtwebkit_examples_and_demos.subdir = $$IN_PWD/qtwebkit-examples-and-demos
qtwebkit_examples_and_demos.target = qtwebkit-examples-and-demos
qtwebkit_examples_and_demos.depends = module_qtwebkit

module_qttools.subdir = $$IN_PWD/qttools
module_qttools.target = module-qttools
module_qttools.depends = module_qtbase module_qtscript module_qtdeclarative module_qt3support module_qtwebkit
win32:module_qttools.depends += module_activeqt

module_qttranslations.subdir = $$IN_PWD/qttranslations
module_qttranslations.target = module-qttranslations
module_qttranslations.depends = module_qttools

module_qtdoc.subdir = $$IN_PWD/qtdoc
module_qtdoc.target = module-qtdoc
module_qtdoc.depends = module_qtdeclarative module_qttools #for the demos and QtHelp

module_activeqt.subdir = $$IN_PWD/qtactiveqt
module_activeqt.target = module-activeqt
module_activeqt.depends = module_qtbase


SUBDIRS       = \
                module_qtbase \
                module_qtsvg \
                module_phonon \
                module_qtxmlpatterns \
                module_qtscript \
                module_qtdeclarative \
                module_qt3support \
                module_qtwebkit \
                module_qtmultimedia \
                module_qttools \
                module_qttranslations \
                module_qtdoc \
                qtwebkit_examples_and_demos \

win32:SUBDIRS += module_activeqt
