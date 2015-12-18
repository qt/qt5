# Create the super cache so modules will add themselves to it.
cache(, super)

CONFIG += build_pass   # hack to disable the .qmake.super auto-add
load(qt_build_config)
CONFIG -= build_pass   # unhack, as it confuses Qt Creator

TEMPLATE      = subdirs

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
