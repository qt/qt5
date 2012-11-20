# Create the super cache so modules will add themselves to it.
cache(, super)

TEMPLATE      = subdirs

CONFIG += prepare_docs

module_qtbase.subdir = qtbase
module_qtbase.target = module-qtbase

module_qtsvg.subdir = qtsvg
module_qtsvg.target = module-qtsvg
module_qtsvg.depends = module_qtbase

module_qtxmlpatterns.subdir = qtxmlpatterns
module_qtxmlpatterns.target = module-qtxmlpatterns
module_qtxmlpatterns.depends = module_qtbase

module_qtscript.subdir = qtscript
module_qtscript.target = module-qtscript
module_qtscript.depends = module_qtbase

module_qtjsbackend.subdir = qtjsbackend
module_qtjsbackend.target = module-qtjsbackend
module_qtjsbackend.depends = module_qtbase

module_qtdeclarative.subdir = qtdeclarative
module_qtdeclarative.target = module-qtdeclarative
module_qtdeclarative.depends = module_qtbase module_qtjsbackend

module_qtwebkit.file = qtwebkit/WebKit.pro
module_qtwebkit.makefile = Makefile
module_qtwebkit.depends = module_qtbase module_qtdeclarative
module_qtwebkit.target = module-qtwebkit

module_qtwebkit_examples_and_demos.subdir = qtwebkit-examples-and-demos
module_qtwebkit_examples_and_demos.target = module-qtwebkit-examples-and-demos
module_qtwebkit_examples_and_demos.depends = module_qtwebkit module_qttools

module_qttools.subdir = qttools
module_qttools.target = module-qttools
module_qttools.depends = module_qtbase

module_qttranslations.subdir = qttranslations
module_qttranslations.target = module-qttranslations
module_qttranslations.depends = module_qttools

module_qtdoc.subdir = qtdoc
module_qtdoc.target = module-qtdoc
module_qtdoc.depends = module_qtbase module_qtdeclarative

module_qtactiveqt.subdir = qtactiveqt
module_qtactiveqt.target = module-qtactiveqt
module_qtactiveqt.depends = module_qtbase

module_qtqa.subdir = qtqa
module_qtqa.target = module-qtqa
module_qtqa.depends = module_qtbase

module_qtmultimedia.subdir = qtmultimedia
module_qtmultimedia.target = module-qtmultimedia
module_qtmultimedia.depends = module_qtbase

module_qtimageformats.subdir = qtimageformats
module_qtimageformats.target = module-qtimageformats
module_qtimageformats.depends = module_qtbase

module_qtquick1.subdir = qtquick1
module_qtquick1.target = module-qtquick1
module_qtquick1.depends = module_qtbase module_qtscript

module_qtgraphicaleffects.subdir = qtgraphicaleffects
module_qtgraphicaleffects.target = module-qtgraphicaleffects
module_qtgraphicaleffects.depends = module_qtbase module_qtdeclarative

# only qtbase is required to exist. The others may not - but it is the
# users responsibility to ensure that all needed dependencies exist, or
# it may not build.

SUBDIRS = module_qtbase

exists(qtsvg/qtsvg.pro) {
    SUBDIRS += module_qtsvg
    # These modules do not require qtsvg, but can use it if it is available
    module_qtdeclarative.depends += module_qtsvg
    module_qtquick1.depends += module_qtsvg
}
exists(qtxmlpatterns/qtxmlpatterns.pro) {
    SUBDIRS += module_qtxmlpatterns
    # These modules do not require qtxmlpatterns, but can use it if it is available
    module_qtdeclarative.depends += module_qtxmlpatterns
    module_qtquick1.depends += module_qtxmlpatterns
}

exists(qtjsbackend/qtjsbackend.pro): SUBDIRS += module_qtjsbackend
exists(qtdeclarative/qtdeclarative.pro) {
    SUBDIRS += module_qtdeclarative
    # These modules do not require qtdeclarative, but can use it if it is available
    module_qttools.depends += module_qtdeclarative
    module_qtmultimedia.depends += module_qtdeclarative
}
exists(qtscript/qtscript.pro): SUBDIRS += module_qtscript
exists(qtmultimedia/qtmultimedia.pro): SUBDIRS += module_qtmultimedia
exists(qtactiveqt/qtactiveqt.pro) {
    SUBDIRS += module_qtactiveqt
    module_qttools.depends += module_qtactiveqt
}
exists(qtwebkit/WebKit.pro) {
    mac|contains(QT_CONFIG, icu) {
        SUBDIRS += module_qtwebkit
        module_qttools.depends += module_qtwebkit
        module_qtquick1.depends += module_qtwebkit
        exists(qtwebkit-examples-and-demos/qtwebkit-examples-and-demos.pro) {
            SUBDIRS += module_qtwebkit_examples_and_demos
        }
    } else {
        message("WebKit: Qt was built without ICU support, WebKit disabled.")
    }
}
exists(qttools/qttools.pro) {
    SUBDIRS += module_qttools
    module_qtquick1.depends += module_qttools
}
exists(qtquick1/qtquick1.pro): SUBDIRS += module_qtquick1
exists(qtimageformats/qtimageformats.pro): SUBDIRS += module_qtimageformats
exists(qtgraphicaleffects/qtgraphicaleffects.pro): SUBDIRS += module_qtgraphicaleffects
exists(qttranslations/qttranslations.pro): SUBDIRS += module_qttranslations
exists(qtdoc/qtdoc.pro): SUBDIRS += module_qtdoc
exists(qtqa/qtqa.pro): SUBDIRS += module_qtqa
