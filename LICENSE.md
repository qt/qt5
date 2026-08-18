Qt licensing
============

Qt is not distributed under a single license, and this file is not a license
text. Qt is available under commercial terms and under several open source
licenses, and which terms apply depends on the module and the file.

The open source licenses in use across the Qt repositories include LGPL-3.0,
GPL-2.0, and GPL-3.0 for module implementations, GFDL-1.3 for documentation,
and BSD-3-Clause for build system files, examples, and tooling. Third-party
code bundled inside a module carries its own terms.


How licensing is declared
-------------------------

Licensing is declared per file, following the
[REUSE version 3.3 specification](https://reuse.software/spec-3.3/). Every file
carries an SPDX-License-Identifier header, or is covered by an adjacent
REUSE.toml file where an inline header is not possible. The full text of every
license referenced this way is in the LICENSES directory of the repository it
applies to.

Those SPDX headers and the LICENSES directory are the authoritative,
machine-readable record for the Qt sources. They are what the REUSE tool and
Qt's software bill of materials pipeline read when generating the SBOM for the
sources; they do not describe the licensing of Qt binaries.


Finding the terms for a module
------------------------------

Each Qt module carries its own licensing, and the terms are stated in the
"Licenses and Attributions" section of that module's documentation overview
page. For example, see:

    https://doc.qt.io/qt-6/qtcore-index.html

That section also lists the third-party code the module includes and the
license of each such component.

License of built modules and tools
----------------------------------

When building Qt, you can build SBOM documents alongside (`-sbom` argument for
`configure`). You can use the generated SBOM artifacts to query copyrights and
licenses for built modules, and tools. For more details, see
[Software Bill of Materials](https://doc.qt.io/qt-6/sbom.html}.

Further information
-------------------

Qt licensing overview
    https://doc.qt.io/qt-6/licensing.html

Licenses used in Qt
    https://doc.qt.io/qt-6/licenses-used-in-qt.html

All Qt modules
    https://doc.qt.io/qt-6/qtmodules.html

Commercial licensing
    https://www.qt.io/licensing/

Open source licensing and its obligations
    https://www.qt.io/download-open-source

Qt educational license
    https://www.qt.io/qt-educational-license
