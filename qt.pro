# Create the super cache so modules will add themselves to it.
cache(, super)

TEMPLATE      = subdirs

CONFIG += prepare_docs qt_docs_targets

# Extract submodules from .gitmodules.
lines = $$cat(.gitmodules, lines)
for (line, lines) {
    mod = $$replace(line, "^\\[submodule \"([^\"]+)\"\\]$", \\1)
    !equals(mod, $$line) {
        module = $$mod
        modules += $$mod
    } else {
        prop = $$replace(line, "^$$escape_expand(\\t)([^ =]+) *=.*$", \\1)
        !equals(prop, $$line) {
            val = $$replace(line, "^[^=]+= *", )
            module.$${module}.$$prop = $$split(val)
        } else {
            error("Malformed line in .gitmodules: $$line")
        }
    }
}
QMAKE_INTERNAL_INCLUDED_FILES += $$PWD/.gitmodules

QT_SKIP_MODULES =
uikit {
    QT_SKIP_MODULES += qtdoc qtmacextras qtserialport qtwebkit qtwebkit-examples
    !ios: QT_SKIP_MODULES += qtscript
}

# This is a bit hacky, but a proper implementation is not worth it.
args = $$QMAKE_EXTRA_ARGS
for (ever) {
    isEmpty(args): break()
    a = $$take_first(args)

    equals(a, -skip) {
        isEmpty(args): break()
        m = $$take_first(args)
        contains(m, -.*): next()
        m ~= s/^(qt)?/qt/
        !contains(modules, $$m): \
            error("-skip command line argument used with non-existent module '$$m'.")
        QT_SKIP_MODULES += $$m
    }
}

modules = $$sort_depends(modules, module., .depends .recommends)
modules = $$reverse(modules)
for (mod, modules) {
    equals(module.$${mod}.qt, false): \
        next()

    deps = $$eval(module.$${mod}.depends)
    recs = $$eval(module.$${mod}.recommends)
    for (d, $$list($$deps $$recs)): \
        !contains(modules, $$d): \
            error("'$$mod' depends on undeclared '$$d'.")

    contains(QT_SKIP_MODULES, $$mod): \
        next()
    !isEmpty(QT_BUILD_MODULES):!contains(QT_BUILD_MODULES, $$mod): \
        next()

    project = $$eval(module.$${mod}.project)
    isEmpty(project) {
        !exists($$mod/$${mod}.pro): \
            next()
        $${mod}.subdir = $$mod
    } else {
        !exists($$mod/$$project): \
            next()
        $${mod}.file = $$mod/$$project
        $${mod}.makefile = Makefile
    }
    $${mod}.target = module-$$mod

    for (d, deps) {
        !contains(SUBDIRS, $$d) {
            $${mod}.target =
            break()
        }
        $${mod}.depends += $$d
    }
    isEmpty($${mod}.target): \
        next()
    for (d, recs) {
        contains(SUBDIRS, $$d): \
            $${mod}.depends += $$d
    }

    SUBDIRS += $$mod
}

load(qt_configure)
