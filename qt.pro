TEMPLATE      = subdirs

module_qtbase.subdir = $$IN_PWD/qtbase
module_qtbase.target = module-qtbase

module_qtsvg.subdir = $$IN_PWD/qtsvg
module_qtsvg.target = module-qtsvg
module_qtsvg.depends = module_qtbase

module_qtphonon.subdir = $$IN_PWD/qtphonon
module_qtphonon.target = module-qtphonon
module_qtphonon.depends = module_qtbase

module_qtxmlpatterns.subdir = $$IN_PWD/qtxmlpatterns
module_qtxmlpatterns.target = module-qtxmlpatterns
module_qtxmlpatterns.depends = module_qtbase

module_qtscript.subdir = $$IN_PWD/qtscript
module_qtscript.target = module-qtscript
module_qtscript.depends = module_qtbase

module_qtdeclarative.subdir = $$IN_PWD/qtdeclarative
module_qtdeclarative.target = module-qtdeclarative
module_qtdeclarative.depends = module_qtbase module_qtsvg module_qtxmlpatterns

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
module_qtdoc.depends = module_qtbase module_qtdeclarative

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
module_qtlocation.depends = module_qtbase module_qtdeclarative module_qtquick3d module_qtscript

module_qtsensors.subdir = $$IN_PWD/qtsensors
module_qtsensors.target = module-qtsensors
module_qtsensors.depends = module_qtbase module_qtdeclarative

module_qtsystems.subdir = $$IN_PWD/qtsystems
module_qtsystems.target = module-qtsystems
module_qtsystems.depends = module_qtbase module_qtdeclarative

module_qtmultimediakit.subdir = $$IN_PWD/qtmultimediakit
module_qtmultimediakit.target = module-qtmultimediakit
module_qtmultimediakit.depends = module_qtbase module_qtdeclarative

module_qtfeedback.subdir = $$IN_PWD/qtfeedback
module_qtfeedback.target = module-qtfeedback
module_qtfeedback.depends = module_qtbase module_qtmultimediakit module_qtdeclarative

module_qtquick3d.subdir = $$IN_PWD/qtquick3d
module_qtquick3d.target = module-qtquick3d
module_qtquick3d.depends = module_qtbase module_qtdeclarative

module_qtdocgallery.subdir = $$IN_PWD/qtdocgallery
module_qtdocgallery.target = module-qtdocgallery
module_qtdocgallery.depends = module_qtbase module_qtscript module_qtdeclarative

module_qtpim.subdir = $$IN_PWD/qtpim
module_qtpim.target = module-qtpim
module_qtpim.depends = module_qtdeclarative

module_qtconnectivity.subdir = $$IN_PWD/qtconnectivity
module_qtconnectivity.target = module-qtconnectivity
module_qtconnectivity.depends = module_qtsystems

module_qtwayland.subdir = $$IN_PWD/qtwayland
module_qtwayland.target = module-qtwayland
module_qtwayland.depends = module_qtbase
# not yet enabled by default
module_qtwayland.CONFIG = no_default_target no_default_install

# only qtbase is required to exist. The others may not - but it is the
# users responsibility to ensure that all needed dependencies exist, or
# it may not build.

SUBDIRS = module_qtbase

exists(qtsvg/qtsvg.pro): SUBDIRS += module_qtsvg
exists(qtphonon/qtphonon.pro): SUBDIRS += module_qtphonon
exists(qtxmlpatterns/qtxmlpatterns.pro): SUBDIRS += module_qtxmlpatterns
exists(qtscript/qtscript.pro): SUBDIRS += module_qtscript
exists(qtdeclarative/qtdeclarative.pro): SUBDIRS += module_qtdeclarative
exists(qttools/qttools.pro): SUBDIRS += module_qttools
exists(qttranslations/qttranslations.pro): SUBDIRS += module_qttranslations
exists(qtdoc/qtdoc.pro): SUBDIRS += module_qtdoc
exists(qlalr/qlalr.pro): SUBDIRS += module_qlalr
exists(qtqa/qtqa.pro): SUBDIRS += module_qtqa
exists(qtlocation/qtlocation.pro): SUBDIRS += module_qtlocation
exists(qtactiveqt/qtactiveqt.pro): SUBDIRS += module_qtactiveqt
exists(qtsensors/qtsensors.pro): SUBDIRS += module_qtsensors
exists(qtsystems/qtsystems.pro): SUBDIRS += module_qtsystems
exists(qtmultimediakit/qtmultimediakit.pro): SUBDIRS += module_qtmultimediakit
exists(qtfeedback/qtfeedback.pro): SUBDIRS += module_qtfeedback
exists(qtquick3d/qtquick3d.pro): SUBDIRS += module_qtquick3d
exists(qtdocgallery/qtdocgallery.pro): SUBDIRS += module_qtdocgallery
exists(qtpim/qtpim.pro): SUBDIRS += module_qtpim
exists(qtconnectivity/qtconnectivity.pro): SUBDIRS += module_qtconnectivity
exists(qtwayland/qtwayland.pro): SUBDIRS += module_qtwayland

exists(qtwebkit/Tools/Scripts/build-webkit) {
    SUBDIRS +=  module_qtwebkit \
                module_qtwebkit_examples_and_demos
    module_qttools.depends += module_qtwebkit
}
