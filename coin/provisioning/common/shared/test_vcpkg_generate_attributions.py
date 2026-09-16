#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

"""Unit tests for vcpkg_generate_attributions.py.

Run from this directory with:
    python3 -m unittest test_vcpkg_generate_attributions -v
"""

import json
import tempfile
import unittest
from pathlib import Path

from vcpkg_generate_attributions import (
    build_attribution,
    find_purl,
    generate,
    index_entries,
    normalize_license,
    port_installs_files,
    select_download_location,
    strip_port_version,
)

TRIPLET = "arm64-ohos-qt"

FREETYPE_PORT = {
    "name": "freetype",
    "SPDXID": "SPDXRef-port",
    "versionInfo": "2.14.3",
    "homepage": "https://www.freetype.org/",
    "licenseConcluded": "(FTL OR GPL-2.0-or-later)",
    "description": "A library to render fonts.",
    "externalRefs": [
        {
            "referenceCategory": "PACKAGE-MANAGER",
            "referenceType": "purl",
            "referenceLocator": "pkg:vcpkg/freetype@2.14.3?triplet=arm64-ohos-qt",
        }
    ],
}

FREETYPE_RESOURCE = {
    "SPDXID": "SPDXRef-resource-0",
    "name": "freetype/freetype",
    "downloadLocation": "git+https://gitlab.freedesktop.org//freetype/freetype@VER-2-14-3",
}

MESON_RESOURCE = {
    "SPDXID": "SPDXRef-resource-0",
    "name": "meson-1.9.0.tar.gz",
    "downloadLocation": "https://github.com/mesonbuild/meson/archive/1.9.0.tar.gz",
}


class TestStripPortVersion(unittest.TestCase):
    def test_plain_version_is_unchanged(self):
        self.assertEqual(strip_port_version("2.14.3"), "2.14.3")

    def test_port_version_suffix_is_dropped(self):
        self.assertEqual(strip_port_version("2.17.1#3"), "2.17.1")

    def test_date_version_is_unchanged(self):
        self.assertEqual(strip_port_version("2024-04-23"), "2024-04-23")

    def test_empty_stays_empty(self):
        self.assertEqual(strip_port_version(""), "")


class TestNormalizeLicense(unittest.TestCase):
    def test_expression_is_kept(self):
        self.assertEqual(normalize_license("MIT"), "MIT")

    def test_compound_expression_is_kept(self):
        self.assertEqual(
            normalize_license("(FTL OR GPL-2.0-or-later)"), "(FTL OR GPL-2.0-or-later)"
        )

    def test_noassertion_is_rejected(self):
        self.assertIsNone(normalize_license("NOASSERTION"))

    def test_vcpkg_null_marker_is_rejected(self):
        self.assertIsNone(normalize_license("LicenseRef-vcpkg-null"))

    def test_missing_is_rejected(self):
        self.assertIsNone(normalize_license(None))

    def test_empty_is_rejected(self):
        self.assertIsNone(normalize_license(""))


class TestFindPurl(unittest.TestCase):
    def test_purl_is_found(self):
        self.assertEqual(
            find_purl(FREETYPE_PORT["externalRefs"]),
            "pkg:vcpkg/freetype@2.14.3?triplet=arm64-ohos-qt",
        )

    def test_other_reference_types_are_ignored(self):
        refs = [{"referenceType": "cpe23Type", "referenceLocator": "cpe:2.3:a:x:y:1:"}]
        self.assertIsNone(find_purl(refs))

    def test_missing_refs_are_tolerated(self):
        self.assertIsNone(find_purl(None))


class TestSelectDownloadLocation(unittest.TestCase):
    def test_single_resource_is_used(self):
        self.assertEqual(
            select_download_location([FREETYPE_RESOURCE]),
            "git+https://gitlab.freedesktop.org//freetype/freetype@VER-2-14-3",
        )

    def test_two_resources_are_ambiguous(self):
        self.assertIsNone(select_download_location([MESON_RESOURCE, FREETYPE_RESOURCE]))

    def test_no_resources_yields_nothing(self):
        self.assertIsNone(select_download_location([]))


class TestPortInstallsFiles(unittest.TestCase):
    def test_library_counts_as_installed(self):
        lines = [
            "arm64-ohos-qt/",
            "arm64-ohos-qt/lib/",
            "arm64-ohos-qt/lib/libfreetype.a",
            "arm64-ohos-qt/share/freetype/copyright",
        ]
        self.assertTrue(port_installs_files(lines, TRIPLET))

    def test_headers_count_as_installed(self):
        lines = ["arm64-ohos-qt/include/node_api.h"]
        self.assertTrue(port_installs_files(lines, TRIPLET))

    def test_metaport_installs_nothing(self):
        lines = [
            "arm64-ohos-qt/",
            "arm64-ohos-qt/share/",
            "arm64-ohos-qt/share/pthread/copyright",
            "arm64-ohos-qt/share/pthread/vcpkg.spdx.json",
        ]
        self.assertFalse(port_installs_files(lines, TRIPLET))

    def test_tools_only_installs_nothing_linkable(self):
        lines = ["arm64-ohos-qt/tools/gperf/gperf"]
        self.assertFalse(port_installs_files(lines, TRIPLET))

    def test_other_triplets_are_ignored(self):
        lines = ["x64-linux/lib/libfreetype.a"]
        self.assertFalse(port_installs_files(lines, TRIPLET))


class TestIndexEntries(unittest.TestCase):
    def test_triplet_component_is_stripped(self):
        lines = ["arm64-ohos-qt/lib/libfreetype.a"]
        self.assertEqual(
            index_entries(lines, TRIPLET, "freetype"), {"lib/libfreetype.a": "freetype"}
        )

    def test_bin_entries_are_indexed(self):
        lines = ["arm64-ohos-qt/bin/libfreetype.so"]
        self.assertEqual(
            index_entries(lines, TRIPLET, "freetype"), {"bin/libfreetype.so": "freetype"}
        )

    def test_headers_are_not_indexed(self):
        lines = ["arm64-ohos-qt/include/ft2build.h"]
        self.assertEqual(index_entries(lines, TRIPLET, "freetype"), {})

    def test_share_is_not_indexed(self):
        lines = ["arm64-ohos-qt/share/freetype/copyright"]
        self.assertEqual(index_entries(lines, TRIPLET, "freetype"), {})

    def test_directory_entries_are_skipped(self):
        lines = ["arm64-ohos-qt/lib/"]
        self.assertEqual(index_entries(lines, TRIPLET, "freetype"), {})


class TestBuildAttribution(unittest.TestCase):
    def test_full_entry(self):
        entry = build_attribution(FREETYPE_PORT, [FREETYPE_RESOURCE], TRIPLET, True)
        self.assertEqual(entry["Id"], "freetype")
        self.assertEqual(entry["Name"], "freetype")
        self.assertEqual(entry["Version"], "2.14.3")
        self.assertEqual(entry["Description"], "A library to render fonts.")
        self.assertEqual(entry["Homepage"], "https://www.freetype.org/")
        self.assertEqual(entry["License"], "(FTL OR GPL-2.0-or-later)")
        self.assertEqual(entry["LicenseId"], "(FTL OR GPL-2.0-or-later)")
        self.assertEqual(entry["LicenseFile"], "copyright")
        self.assertEqual(entry["PURL"], "pkg:vcpkg/freetype@2.14.3?triplet=arm64-ohos-qt")
        self.assertEqual(
            entry["DownloadLocation"],
            "git+https://gitlab.freedesktop.org//freetype/freetype@VER-2-14-3",
        )
        self.assertIn(TRIPLET, entry["QtUsage"])

    def test_port_version_is_stripped_from_version_but_not_purl(self):
        port = dict(FREETYPE_PORT)
        port["versionInfo"] = "2.17.1#3"
        port["externalRefs"] = [
            {
                "referenceType": "purl",
                "referenceLocator": "pkg:vcpkg/fontconfig@2.17.1#3?triplet=arm64-ohos-qt",
            }
        ]
        entry = build_attribution(port, [], TRIPLET, False)
        self.assertEqual(entry["Version"], "2.17.1")
        self.assertEqual(entry["PURL"], "pkg:vcpkg/fontconfig@2.17.1#3?triplet=arm64-ohos-qt")

    def test_missing_copyright_omits_license_file(self):
        entry = build_attribution(FREETYPE_PORT, [FREETYPE_RESOURCE], TRIPLET, False)
        self.assertNotIn("LicenseFile", entry)

    def test_unusable_license_is_omitted(self):
        port = dict(FREETYPE_PORT)
        port["licenseConcluded"] = "LicenseRef-vcpkg-null"
        entry = build_attribution(port, [], TRIPLET, False)
        self.assertNotIn("License", entry)
        self.assertNotIn("LicenseId", entry)

    def test_ambiguous_resources_omit_download_location(self):
        entry = build_attribution(
            FREETYPE_PORT, [MESON_RESOURCE, FREETYPE_RESOURCE], TRIPLET, False
        )
        self.assertNotIn("DownloadLocation", entry)

    def test_sparse_port_yields_minimal_entry(self):
        port = {"name": "dirent", "SPDXID": "SPDXRef-port", "versionInfo": "1.26"}
        entry = build_attribution(port, [], TRIPLET, False)
        self.assertEqual(entry["Id"], "dirent")
        self.assertEqual(entry["Version"], "1.26")
        self.assertNotIn("Description", entry)
        self.assertNotIn("Homepage", entry)
        self.assertNotIn("License", entry)
        self.assertNotIn("PURL", entry)


class TestGenerate(unittest.TestCase):
    def setUp(self):
        self._temp = tempfile.TemporaryDirectory()
        self.root = Path(self._temp.name)
        self.addCleanup(self._temp.cleanup)

    def _write_port(self, port_name, port_package, resources, list_lines=None, copyright_text=None):
        port_dir = self.root / TRIPLET / "share" / port_name
        port_dir.mkdir(parents=True)
        document = {"packages": [port_package] + resources}
        (port_dir / "vcpkg.spdx.json").write_text(json.dumps(document), encoding="utf-8")
        if copyright_text is not None:
            (port_dir / "copyright").write_text(copyright_text, encoding="utf-8")
        if list_lines is not None:
            info_dir = self.root / "vcpkg" / "info"
            info_dir.mkdir(parents=True, exist_ok=True)
            version = strip_port_version(port_package.get("versionInfo", "0"))
            list_path = info_dir / f"{port_name}_{version}_{TRIPLET}.list"
            list_path.write_text("\n".join(list_lines) + "\n", encoding="utf-8")

    def test_writes_attribution_and_index(self):
        self._write_port(
            "freetype",
            FREETYPE_PORT,
            [FREETYPE_RESOURCE],
            [
                f"{TRIPLET}/lib/libfreetype.a",
                f"{TRIPLET}/include/ft2build.h",
                f"{TRIPLET}/share/freetype/copyright",
            ],
            copyright_text="FREETYPE LICENSES\n",
        )

        generate(self.root, TRIPLET)

        attribution_path = self.root / TRIPLET / "share" / "freetype" / "qt_attribution.json"
        entries = json.loads(attribution_path.read_text(encoding="utf-8"))
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["Id"], "freetype")
        self.assertEqual(entries[0]["Version"], "2.14.3")
        self.assertEqual(entries[0]["LicenseFile"], "copyright")

        index_path = self.root / TRIPLET / "share" / "qt_vcpkg_ports.json"
        index = json.loads(index_path.read_text(encoding="utf-8"))
        self.assertEqual(index, {"lib/libfreetype.a": "freetype"})

    def test_metaport_is_skipped(self):
        metaport = {
            "name": "pthread",
            "SPDXID": "SPDXRef-port",
            "versionInfo": "3.0.0#2",
            "licenseConcluded": "NOASSERTION",
        }
        self._write_port(
            "pthread", metaport, [], [f"{TRIPLET}/share/pthread/vcpkg.spdx.json"]
        )

        generate(self.root, TRIPLET)

        self.assertFalse(
            (self.root / TRIPLET / "share" / "pthread" / "qt_attribution.json").exists()
        )

    def test_directory_without_spdx_document_is_ignored(self):
        stray = self.root / TRIPLET / "share" / "unofficial-brotli"
        stray.mkdir(parents=True)
        (stray / "unofficial-brotli-config.cmake").write_text("", encoding="utf-8")
        (self.root / "vcpkg" / "info").mkdir(parents=True)

        generate(self.root, TRIPLET)

        self.assertFalse((stray / "qt_attribution.json").exists())

    def test_missing_list_file_emits_attribution_anyway(self):
        # The core failure mode this script exists to fix: emit attribution
        # even when the .list file is missing, so real libraries are not hidden.
        # The info dir itself still exists here; only this one port's .list is missing.
        (self.root / "vcpkg" / "info").mkdir(parents=True)
        self._write_port(
            "expat",
            {
                "name": "expat",
                "SPDXID": "SPDXRef-port",
                "versionInfo": "2.6.2",
                "licenseConcluded": "MIT",
            },
            [],
            list_lines=None,  # No .list file
        )

        generate(self.root, TRIPLET)

        attribution_path = self.root / TRIPLET / "share" / "expat" / "qt_attribution.json"
        self.assertTrue(attribution_path.exists())
        entries = json.loads(attribution_path.read_text(encoding="utf-8"))
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["Id"], "expat")

        index_path = self.root / TRIPLET / "share" / "qt_vcpkg_ports.json"
        index = json.loads(index_path.read_text(encoding="utf-8"))
        self.assertEqual(index, {})  # No paths to index without .list file

    def test_missing_info_dir_fails(self):
        # Distinguish "no install database at all" from "one port is missing its
        # .list": the former must fail loudly rather than silently emptying the
        # index for every port, which is what Path.glob on a missing dir would do.
        self._write_port(
            "expat",
            {
                "name": "expat",
                "SPDXID": "SPDXRef-port",
                "versionInfo": "2.6.2",
                "licenseConcluded": "MIT",
            },
            [],
        )

        with self.assertRaises(SystemExit):
            generate(self.root, TRIPLET)


if __name__ == "__main__":
    unittest.main()
