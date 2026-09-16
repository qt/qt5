#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

"""Convert the SPDX documents vcpkg installs into qt_attribution.json files.

vcpkg writes share/<port>/vcpkg.spdx.json for every installed port; Qt's SBOM
machinery reads qt_attribution.json. Bridging the two gets vcpkg-provided
third-party libraries into Qt's SBOM with license, version and provenance
information, without duplicating that data in Qt repositories.
"""

import argparse
import json
from pathlib import Path

# vcpkg's markers for "no license recorded". The second one is what a port whose
# manifest says "license": null produces.
UNUSABLE_LICENSES = frozenset(["", "NOASSERTION", "NONE", "LicenseRef-vcpkg-null"])

# A port that installs only into these provides nothing linkable.
METADATA_DIRS = ("share/", "tools/")

# Only these can show up as an IMPORTED_LOCATION, so only these go into the index.
INDEXED_DIRS = ("lib/", "bin/")


def strip_port_version(version_info):
    """Drop vcpkg's '#N' port-version suffix, keeping the upstream version.

    The suffix is a packaging revision, so leaving it in would break version
    matching against advisory data.
    """
    return version_info.split("#", 1)[0]


def normalize_license(expression):
    """Return the SPDX license expression, or None when vcpkg recorded none."""
    if expression is None or expression in UNUSABLE_LICENSES:
        return None
    return expression


def find_purl(external_refs):
    for reference in external_refs or []:
        if reference.get("referenceType") == "purl":
            return reference.get("referenceLocator")
    return None


def select_download_location(resources):
    """Return the port's source URL, but only when it is unambiguous.

    vcpkg lists downloads in the order they happened, so build tools, patches and
    license files share the list with the source, and neither the first nor the
    last entry identifies it. With one resource there is nothing to confuse.
    """
    if len(resources) != 1:
        return None
    return resources[0].get("downloadLocation") or None


def _installed_paths(list_lines, triplet):
    """Yield the prefix-relative path of every file in a vcpkg .list file."""
    prefix = triplet + "/"
    for line in list_lines:
        entry = line.strip()
        if not entry or entry.endswith("/") or not entry.startswith(prefix):
            continue
        yield entry[len(prefix):]


def port_installs_files(list_lines, triplet):
    """True when the port installs something outside share/ and tools/.

    Metaports such as 'pthread' exist only to depend on other ports, so they can
    never be linked and have no place in the SBOM.
    """
    for relative in _installed_paths(list_lines, triplet):
        if not relative.startswith(METADATA_DIRS):
            return True
    return False


def index_entries(list_lines, triplet, port_name):
    """Map prefix-relative library paths to the port that owns them.

    Keys are relative to the prefix so that the same index serves both layouts Qt
    is configured against: the vcpkg installed tree and the flattened developer
    archive, which both have lib/ directly under the prefix.
    """
    return {
        relative: port_name
        for relative in _installed_paths(list_lines, triplet)
        if relative.startswith(INDEXED_DIRS)
    }


def build_attribution(port_package, resources, triplet, has_copyright):
    """Map a vcpkg SPDXRef-port package onto a qt_attribution.json entry."""
    name = port_package["name"]
    entry = {
        "Id": name,
        "Name": name,
        "QtUsage": (
            f"Provided by vcpkg for the {triplet} triplet. "
            "Linked into Qt when Qt is built against this vcpkg prefix."
        ),
    }

    version = strip_port_version(port_package.get("versionInfo", ""))
    if version:
        entry["Version"] = version

    for key, source_key in (("Description", "description"), ("Homepage", "homepage")):
        value = port_package.get(source_key)
        if value:
            entry[key] = value

    license_expression = normalize_license(port_package.get("licenseConcluded"))
    if license_expression:
        entry["License"] = license_expression
        entry["LicenseId"] = license_expression

    if has_copyright:
        entry["LicenseFile"] = "copyright"

    purl = find_purl(port_package.get("externalRefs"))
    if purl:
        entry["PURL"] = purl

    download_location = select_download_location(resources)
    if download_location:
        entry["DownloadLocation"] = download_location

    return entry


def read_port_document(spdx_path):
    """Return the SPDXRef-port package and the resource packages of an SPDX document."""
    with open(spdx_path, encoding="utf-8") as handle:
        document = json.load(handle)

    packages = document.get("packages", [])
    port_package = next(
        (package for package in packages if package.get("SPDXID") == "SPDXRef-port"), None
    )
    resources = [
        package
        for package in packages
        if str(package.get("SPDXID", "")).startswith("SPDXRef-resource")
    ]
    return port_package, resources


def find_list_file(info_dir, port_name, triplet):
    """Locate a port's vcpkg .list file.

    The file name omits the port-version altogether (fontconfig's SPDX document
    says 'versionInfo: 2.17.1#3', but its .list file is
    'fontconfig_2.17.1_arm64-ohos-qt.list'), so glob on the port and triplet
    components instead of trying to reconstruct the exact file name.
    """
    matches = sorted(info_dir.glob(f"{port_name}_*_{triplet}.list"))
    if len(matches) == 1:
        return matches[0]
    return None


def generate(install_root, triplet):
    share_dir = install_root / triplet / "share"
    info_dir = install_root / "vcpkg" / "info"

    if not share_dir.is_dir():
        raise SystemExit(f"error: no such directory: {share_dir}")

    # Path.glob on a missing directory silently yields nothing, which would otherwise make
    # every port look like it has no .list file and write an empty index for the whole tree.
    if not info_dir.is_dir():
        raise SystemExit(f"error: no such directory: {info_dir}")

    index = {}
    written = []
    skipped = []
    unusable_license = []

    for spdx_path in sorted(share_dir.glob("*/vcpkg.spdx.json")):
        port_dir = spdx_path.parent
        port_package, resources = read_port_document(spdx_path)
        if port_package is None:
            raise SystemExit(f"error: no SPDXRef-port package in {spdx_path}")

        port_name = port_package["name"]
        list_file = find_list_file(info_dir, port_name, triplet)

        if list_file is None:
            # Emitting nothing would hide a real library, which is the very gap
            # this script exists to close.
            print(f"warning: no .list file for port '{port_name}' under {info_dir}")
            list_lines = []
        else:
            list_lines = list_file.read_text(encoding="utf-8").splitlines()
            if not port_installs_files(list_lines, triplet):
                skipped.append(port_name)
                continue
            index.update(index_entries(list_lines, triplet, port_name))

        entry = build_attribution(
            port_package, resources, triplet, (port_dir / "copyright").is_file()
        )
        if "License" not in entry:
            unusable_license.append(port_name)

        with open(port_dir / "qt_attribution.json", "w", encoding="utf-8") as handle:
            json.dump([entry], handle, indent=4, sort_keys=True)
            handle.write("\n")
        written.append(port_name)

    with open(share_dir / "qt_vcpkg_ports.json", "w", encoding="utf-8") as handle:
        json.dump(index, handle, indent=4, sort_keys=True)
        handle.write("\n")

    print(f"Wrote {len(written)} qt_attribution.json file(s) under {share_dir}")
    print(f"Indexed {len(index)} installed librar(y/ies) in qt_vcpkg_ports.json")
    if skipped:
        print(f"Skipped {len(skipped)} port(s) installing no files: {', '.join(skipped)}")
    for port_name in unusable_license:
        print(f"warning: port '{port_name}' has no usable license expression")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--install-root",
        required=True,
        type=Path,
        help="vcpkg install root, the directory holding <triplet>/ and vcpkg/info/",
    )
    parser.add_argument(
        "--triplet", required=True, help="vcpkg triplet, for example arm64-ohos-qt"
    )
    arguments = parser.parse_args()
    generate(arguments.install_root.resolve(), arguments.triplet)


if __name__ == "__main__":
    main()
