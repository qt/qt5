# Wrapper profile for QtWebkit.
#
# This is needed because webkit builds via a script.
# Technically this script is a .pro file, but we name it .pri to avoid clashing
# with qt.pro.

isEmpty(vcproj) {
    QMAKE_LINK = @: IGNORE THIS LINE
    OBJECTS_DIR =
    win32:CONFIG -= embed_manifest_exe
} else {
    CONFIG += console
    PHONY_DEPS = .
    phony_src.input = PHONY_DEPS
    phony_src.output = phony.c
    phony_src.variable_out = GENERATED_SOURCES
    phony_src.commands = echo int main() { return 0; } > phony.c
    phony_src.name = CREATE phony.c
    phony_src.CONFIG += combine
    QMAKE_EXTRA_COMPILERS += phony_src
}

DS = $$QMAKE_DIR_SEP
contains(DS, /) {
    env_export = export
    OPTI=+
    SBC=$$quote($$QMAKE_CHK_DIR_EXISTS qtwebkit || mkdir qtwebkit &&)
} else {
    env_export = set
    GNUTOOLS = $$quote("set \"PATH=$$PWD/gnuwin32/bin;%PATH%\" &&")
}

exists($$PWD/qtwebkit/WebKitTools):qtwebkit_tools_dir = WebKitTools
else:qtwebkit_tools_dir = Tools

QTWEBKIT_BUILD_CONFIG =
contains(CONFIG, release):!contains(CONFIG, debug_and_release): {QTWEBKIT_BUILD_CONFIG = --release}

# The '+' is to make parallel "make" work across the script boundary.
module_qtwebkit.commands = $${OPTI}$${SBC}cd qtwebkit && \
                           $$env_export \"WEBKITOUTPUTDIR=$$OUT_PWD/qtwebkit/WebKitBuild\" && $$GNUTOOLS \
                           perl $$PWD$${DS}qtwebkit$${DS}$${qtwebkit_tools_dir}$${DS}Scripts$${DS}build-webkit \
                               --qt \
                               --qmake=$(QMAKE) \
                               --install-libs=$$[QT_INSTALL_LIBS] \
                               $$QTWEBKIT_BUILD_CONFIG
#                               "--makeargs=\"-$(MAKEFLAGS)\""
# Trick to force dependency on this rule.
#module_qtwebkit.commands += $$escape_expand(\\n)make_default: module-qtwebkit
module_qtwebkit.target = module-qtwebkit

# The '+' is to make parallel "make" work across the script boundary.
module_qtwebkit_clean.commands = $${OPTI}$${SBC}cd qtwebkit && \
                                 $$env_export \"WEBKITOUTPUTDIR=$$OUT_PWD/qtwebkit/WebKitBuild\" && $$GNUTOOLS \
                                 perl $$PWD$${DS}qtwebkit$${DS}$${qtwebkit_tools_dir}$${DS}Scripts$${DS}build-webkit \
                                     --qt \
                                     --qmake=$(QMAKE) \
                                     --install-libs=$$[QT_INSTALL_LIBS] \
                                     $$QTWEBKIT_BUILD_CONFIG \
                                     "--makeargs=\"$(MAKEFLAGS)\"" \
                                     --clean
# Trick to force dependency on this rule.
module_qtwebkit_clean.commands += $$escape_expand(\\n)clean: module-qtwebkit-clean
module_qtwebkit_clean.target = module-qtwebkit-clean

module_qtwebkit_install.commands = $${OPTI}$${SBC}cd qtwebkit && \
                           $$env_export \"WEBKITOUTPUTDIR=$$OUT_PWD/qtwebkit/WebKitBuild\" && $$GNUTOOLS \
                           perl $$PWD$${DS}qtwebkit$${DS}$${qtwebkit_tools_dir}$${DS}Scripts$${DS}build-webkit \
                               --qt \
                               --qmake=$(QMAKE) \
                               --install-libs=$$[QT_INSTALL_LIBS] \
                               "--makeargs=\"install\""
# Trick to force dependency on this rule.
module_qtwebkit_install.commands+= $$escape_expand(\\n)install: module-qtwebkit-install
module_qtwebkit_install.target = module-qtwebkit-install

module_qtwebkit_uninstall.commands = $${OPTI}$${SBC}cd qtwebkit && \
                           $$env_export \"WEBKITOUTPUTDIR=$$OUT_PWD/qtwebkit/WebKitBuild\" && $$GNUTOOLS \
                           perl $$PWD$${DS}qtwebkit$${DS}$${qtwebkit_tools_dir}$${DS}Scripts$${DS}build-webkit \
                               --qt \
                               --qmake=$(QMAKE) \
                               --install-libs=$$[QT_INSTALL_LIBS] \
                               "--makeargs=\"uninstall\""
# Trick to force dependency on this rule.
module_qtwebkit_uninstall.commands+= $$escape_expand(\\n)uninstall: module-qtwebkit-uninstall
module_qtwebkit_uninstall.target = module-qtwebkit-uninstall

# WebKit needs a nonstandard target because the build has to be initiated by the bundled script.
QMAKE_EXTRA_TARGETS += module_qtwebkit module_qtwebkit_clean module_qtwebkit_install module_qtwebkit_uninstall
PRE_TARGETDEPS += module-qtwebkit
