# Create the super cache so modules will add themselves to it.
cache(, super)

CONFIG += build_pass   # hack to disable the .qmake.super auto-add
load(qt_build_config)

TEMPLATE      = subdirs

defineReplace(moduleName) {
    return(module_$$replace(1, -, _))
}

# Arguments: module name, [mandatory deps], [optional deps], [project file]
defineTest(addModule) {
    contains(QT_SKIP_MODULES, $$1): return(false)
    mod = $$moduleName($$1)

    isEmpty(4) {
        !exists($$1/$${1}.pro): return(false)
        $${mod}.subdir = $$1
        export($${mod}.subdir)
    } else {
        !exists($$1/$${4}): return(false)
        $${mod}.file = $$1/$$4
        $${mod}.makefile = Makefile
        export($${mod}.file)
        export($${mod}.makefile)
    }

    for(d, 2) {
        dn = $$moduleName($$d)
        !contains(SUBDIRS, $$dn): \
            return(false)
        $${mod}.depends += $$dn
    }
    for(d, 3) {
        dn = $$moduleName($$d)
        contains(SUBDIRS, $$dn): \
            $${mod}.depends += $$dn
    }
    !isEmpty($${mod}.depends): \
        export($${mod}.depends)

    $${mod}.target = module-$$1
    export($${mod}.target)

    SUBDIRS += $$mod
    export(SUBDIRS)
    return(true)
}

# only qtbase is required to exist. The others may not - but it is the
# users responsibility to ensure that all needed dependencies exist, or
# it may not build.

addModule(qtbase)
addModule(qtx11extras, qtbase)
addModule(qlalr, qtbase)
addModule(qtsvg, qtbase)
addModule(qtxmlpatterns, qtbase)
addModule(qtjsbackend, qtbase)
addModule(qtdeclarative, qtjsbackend, qtsvg qtxmlpatterns)
addModule(qtquickcontrols, qtdeclarative)
addModule(qtmultimedia, qtdeclarative)
addModule(qtactiveqt, qtbase)
addModule(qt3d, qtdeclarative)
addModule(qtjsondb, qtdeclarative)
addModule(qtsystems, qtbase, qtdeclarative qtjsondb)
addModule(qtlocation, qtbase, qt3d qtjsondb qtsystems qtmultimedia)
addModule(qtsensors, qtbase, qtdeclarative)
addModule(qtconnectivity, qtsystems)
addModule(qtfeedback, qtdeclarative, qtmultimedia)
addModule(qtpim, qtdeclarative, qtjsondb)
addModule(qtwebkit, qtdeclarative, qtlocation qtsensors, WebKit.pro)
addModule(qttools, qtbase, qtdeclarative qtactiveqt qtwebkit)
addModule(qtwebkit-examples, qtwebkit qttools)
addModule(qtimageformats, qtbase)
addModule(qtgraphicaleffects, qtdeclarative)
addModule(qtscript, qtbase)
addModule(qtquick1, qtscript, qtsvg qtxmlpatterns qtwebkit qttools)
addModule(qtdocgallery, qtdeclarative, qtjsondb)
!win32:!mac:addModule(qtwayland, qtbase, qtdeclarative)
addModule(qtserialport, qtbase)
addModule(qttranslations, qttools)
addModule(qtdoc, qtdeclarative)
addModule(qtqa, qtbase)
