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

    for(d, 2): \
        $${mod}.depends += $$moduleName($$d)
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
addModule(qtsvg, qtbase)
addModule(qtxmlpatterns, qtbase)
addModule(qtjsbackend, qtbase)
addModule(qtdeclarative, qtjsbackend, qtsvg qtxmlpatterns)
addModule(qtmultimedia, qtbase, qtdeclarative)
addModule(qtactiveqt, qtbase)
addModule(qtwebkit, qtdeclarative, , WebKit.pro)
addModule(qttools, qtbase, qtdeclarative qtactiveqt qtwebkit)
addModule(qtwebkit-examples-and-demos, qtwebkit qttools)
addModule(qtimageformats, qtbase)
addModule(qtgraphicaleffects, qtdeclarative)
addModule(qtscript, qtbase)
addModule(qtquick1, qtscript, qtsvg qtxmlpatterns qtwebkit qttools)
addModule(qttranslations, qttools)
addModule(qtdoc, qtdeclarative)
addModule(qtqa, qtbase)
