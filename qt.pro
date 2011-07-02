TEMPLATE      = subdirs

module_qtbase.subdir = $$IN_PWD/qtbase
module_qtbase.target = module-qtbase

module_qtsvg.subdir = $$IN_PWD/qtsvg
module_qtsvg.target = module-qtsvg
module_qtsvg.depends = module_qtbase

module_qtphonon.subdir = $$IN_PWD/qtphonon
module_qtphonon.target = module-qtphonon
module_qtphonon.depends = module_qtbase

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

module_qtwebkit.file = qtwebkit.pri
module_qtwebkit.makefile = Makefile.qtwebkit
module_qtwebkit.depends = module_qtbase module_qtscript module_qtdeclarative module_qtphonon
# The qtwebkit subdir does not follow the "module-*" scheme, so make our own target that does.
module_qtwebkit_target.target = module-qtwebkit
module_qtwebkit_target.commands =
module_qtwebkit_target.depends = sub-qtwebkit-pri
QMAKE_EXTRA_TARGETS += module_qtwebkit_target

module_qtwebkit_examples_and_demos.subdir = $$IN_PWD/qtwebkit-examples-and-demos
module_qtwebkit_examples_and_demos.target = module-qtwebkit-examples-and-demos
module_qtwebkit_examples_and_demos.depends = module_qtwebkit

module_qttools.subdir = $$IN_PWD/qttools
module_qttools.target = module-qttools
module_qttools.depends = module_qtbase module_qtscript module_qtdeclarative
win32:module_qttools.depends += module_qtactiveqt

module_qttranslations.subdir = $$IN_PWD/qttranslations
module_qttranslations.target = module-qttranslations
module_qttranslations.depends = module_qttools

module_qtdoc.subdir = $$IN_PWD/qtdoc
module_qtdoc.target = module-qtdoc
module_qtdoc.depends = module_qtdeclarative module_qttools #for the demos and QtHelp

module_qtactiveqt.subdir = $$IN_PWD/qtactiveqt
module_qtactiveqt.target = module-qtactiveqt
module_qtactiveqt.depends = module_qtbase

module_qlalr.subdir = $$IN_PWD/qlalr
module_qlalr.target = module-qlalr
module_qlalr.depends = module_qtbase

module_qtqa.subdir = $$IN_PWD/qtqa
module_qtqa.target = module-qtqa
module_qtqa.depends = module_qtbase

module_qtlocation.subdir = $$IN_PWD/qtlocation
module_qtlocation.target = module-qtlocation
module_qtlocation.depends = module_qtbase module_qtdeclarative

module_qtsensors.subdir = $$IN_PWD/qtsensors
module_qtsensors.target = module-qtsensors
module_qtsensors.depends = module_qtbase module_qtdeclarative

module_qtsystems.subdir = $$IN_PWD/qtsystems
module_qtsystems.target = module-qtsystems
module_qtsystems.depends = module_qtbase module_qtdeclarative

module_qtmultimediakit.subdir = $$IN_PWD/qtmultimediakit
module_qtmultimediakit.target = module-qtmultimediakit
module_qtmultimediakit.depends = module_qtbase module_qtdeclarative
# not yet enabled by default
module_qtmultimediakit.CONFIG = no_default_target no_default_install

SUBDIRS       = \
                module_qtbase \
                module_qtsvg \
                module_qtphonon \
                module_qtxmlpatterns \
                module_qtscript \
                module_qtdeclarative \
                module_qtmultimedia \
                module_qttools \
                module_qttranslations \
                module_qtdoc \
                module_qlalr \
                module_qtqa \
                module_qtlocation \
                module_qtactiveqt \
                module_qtsensors \
                module_qtsystems \
                module_qtmultimediakit \

exists(qtwebkit/Tools/Scripts/build-webkit) {
    SUBDIRS +=  module_qtwebkit \
                module_qtwebkit_examples_and_demos
    module_qttools.depends += module_qtwebkit
}
