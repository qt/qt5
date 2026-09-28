#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg shared libraries.
#
# The script will package iOS and iOS-simulator binaries into one
# single .xcframework. This .xcframework cannot contain .dylibs
# directly. It must contain .framework files. Binaries for different
# SDKs (iphoneos and iphonesimulator) should NOT be lipoed together,
# they must be separate frameworks inside the .xcframework. However,
# an .xcframework can hold only one framework per SDK, so binaries for
# different architectures of the same SDK (arm64 and x86_64 simulator)
# must be lipoed together into a single universal framework.
#
# From https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle
# "Avoid using dynamic library files (.dylib files) for dynamic
# linking. An XCFramework can include dynamic library files, but only
# macOS supports these libraries for dynamic linking. Dynamic linking
# on iOS, iPadOS, tvOS, visionOS, and watchOS requires the XCFramework
# to contain .framework bundles."

default_target_platforms="arm64-iphoneos,arm64-simulator,x86_64-simulator"
default_prefix="/usr/local/ios/ffmpeg"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [--os <abis>] [--output <dir>] [--skip-env-var]

Build FFmpeg shared libraries for iOS, packaged as .xcframeworks.

Options:
  --os <abis>           Comma-separated list of target ABIs. Each one of:
                        arm64-iphoneos, arm64-simulator, x86_64-simulator.
                        ABIs that share the same SDK are lipoed together
                        into one framework.
                        Defaults to $default_target_platforms.
  --output <dir>        Directory to install FFmpeg into.
                        Defaults to $default_prefix.
  --skip-env-var        Don't set the FFMPEG_DIR_IOS environment variable to the
                        installation directory.
  -h, --help            Show this help and exit.

Example:
  $(basename "${BASH_SOURCE[0]}") --os arm64-iphoneos,arm64-simulator --output /usr/local/ios/ffmpeg
EOF
}

os="$default_target_platforms"
prefix="$default_prefix"
skip_env_var="no"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --skip-env-var)
            skip_env_var="yes"
            ;;
        --os|--output)
            if [ $# -lt 2 ]; then
                echo "Error: option '$1' requires a value." >&2
                exit 2
            fi
            case "$1" in
                --os) os="$2" ;;
                --output) prefix="$2" ;;
            esac
            shift
            ;;
        *)
            echo "Error: unknown argument '$1'." >&2
            echo "" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

set -eoux pipefail

target_platform_to_sdk() {
    local target_platform="$1"
    if [[ "$target_platform" == "arm64-simulator" ]] \
        || [[ "$target_platform" == "x86_64-simulator" ]]; then
        echo "iphonesimulator"
    elif [ "$target_platform" == "arm64-iphoneos" ]; then
        echo "iphoneos"
    else
        echo "Error finding corresponding iOS SDK for target platform: ${target_platform}"
        exit 1
    fi
}

target_platforms=()
IFS=',' read -r -a target_platforms <<< "$os"
if [ ${#target_platforms[@]} -eq 0 ]; then
    echo "Error: --os must contain at least one ABI." >&2
    exit 1
fi

# The SDKs of all target platforms, without duplicates. Each SDK ends up as
# a separate framework inside each .xcframework.
target_sdks=()
for target_platform in "${target_platforms[@]}"; do
    target_sdk="$(target_platform_to_sdk "$target_platform")"
    if [[ " ${target_sdks[*]:-} " != *" ${target_sdk} "* ]]; then
        target_sdks+=("$target_sdk")
    fi
done

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_version="n$(<"${ffmpeg_source_dir}/RELEASE")"
if [ ! -n "$ffmpeg_version" ]; then
    echo "Error. Unable to determine FFmpeg version."
    exit 1
fi
ffmpeg_build_type="shared"
ffmpeg_config_options=$(get_ffmpeg_config_options "$ffmpeg_build_type")

# Qt doesn't utilize all FFmpeg components. This is a list of the ones
# we care about
ffmpeg_components="libavcodec libavformat libavutil libswresample libswscale"

# Must match or be lower than the minimum iOS version supported by the version of Qt that is
# currently being built.
MINIMUM_IOS_VERSION="16.0"

build_ffmpeg_ios() {
    local target_platform="$1"
    local target_sdk;
    target_sdk="$(target_platform_to_sdk "${target_platform}")"

    # Target platforms are named <arch>-<sdk>, e.g. arm64-simulator.
    local target_cpu_arch="${target_platform%%-*}"

    local minos
    if [ "$target_sdk" == "iphonesimulator" ]; then
        minos="-mios-simulator-version-min=$MINIMUM_IOS_VERSION"
    else
        minos="-miphoneos-version-min=$MINIMUM_IOS_VERSION"
    fi

    local build_dir="$ffmpeg_source_dir/build_ios/$target_platform"
    sudo mkdir -p "$build_dir"
    pushd "$build_dir"

    local sysroot;
    sysroot="$(xcrun --sdk "${target_sdk}" --show-sdk-path)"
    local cc;
    cc="$(xcrun -f --sdk ${target_sdk} clang)"
    local cxx;
    cxx="$(xcrun -f --sdk ${target_sdk} clang++)"

    # We add -g so we get debug symbols.
    local common_arch_flags="${minos} -arch ${target_cpu_arch} -g"

    local config_parameters=(
        $ffmpeg_config_options
        --sysroot="${sysroot}"
        --enable-cross-compile
        --enable-optimizations
        --prefix="$prefix"
        --arch="$target_cpu_arch"
        --cc="$cc"
        --cxx="$cxx"
        --extra-cflags="${common_arch_flags}"
        --extra-cxxflags="${common_arch_flags}"
        --extra-ldflags="${common_arch_flags}"
        --target-os=darwin
        --install-name-dir="@rpath"

        # We perform manual stripping after generating dSYMs.
        # Make sure to skip it during FFmpeg compilation.
        --disable-stripping
    )
    sudo "$ffmpeg_source_dir/configure" "${config_parameters[@]}"

    sudo make install DESTDIR="$build_dir/installed" -j4
    popd
}

# Combine the FFmpeg dylibs of all target platforms that belong to the given
# SDK into universal dylibs. The result is placed in a build directory named
# after the SDK, which is then used to create the framework for that SDK.
lipo_dylibs() {
    local target_sdk="$1"

    local sdk_lib_dir="${ffmpeg_source_dir}/build_ios/${target_sdk}/installed/${prefix}/lib"
    sudo mkdir -p "$sdk_lib_dir"

    local ffmpeg_component_name
    for ffmpeg_component_name in $ffmpeg_components; do
        local input_dylibs=()
        local target_platform
        for target_platform in "${target_platforms[@]}"; do
            if [ "$(target_platform_to_sdk "$target_platform")" == "$target_sdk" ]; then
                input_dylibs+=("${ffmpeg_source_dir}/build_ios/${target_platform}/installed/${prefix}/lib/${ffmpeg_component_name}.dylib")
            fi
        done

        sudo lipo -create \
            "${input_dylibs[@]}" \
            -output "${sdk_lib_dir}/${ffmpeg_component_name}.dylib"
    done
}

build_info_plist() {
    local file_path="$1"
    local framework_name="$2"
    local framework_id="$3"

    # Apple plist format has a strict requirement that the version string
    # contains up to 3 numerics separated by a dot. Meanwhile, FFmpeg versioning
    # tends to use an 'n' prefix in their versioning. We use a regex to convert
    # and verify the version string.
    #
    # https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleversion
    local formatted_ffmpeg_version
    if [[ $ffmpeg_version =~ ([0-9]+(\.[0-9]+){0,2}) ]]; then
        formatted_ffmpeg_version="${BASH_REMATCH[1]}"
    else
        echo "Unable to format FFmpeg version string '$ffmpeg_version' into corresponding Apple Info.plist format"
        exit 1
    fi

    local minimum_version_key="MinimumOSVersion"
    local supported_platforms="iPhoneOS"

    info_plist="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${framework_name}</string>
    <key>CFBundleIdentifier</key>
    <string>${framework_id}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${framework_name}</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>${formatted_ffmpeg_version}</string>
    <key>CFBundleVersion</key>
    <string>${formatted_ffmpeg_version}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>${minimum_version_key}</key>
    <string>${MINIMUM_IOS_VERSION}</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>${supported_platforms}</string>
    </array>
    <key>NSPrincipalClass</key>
    <string></string>
</dict>
</plist>"
    echo $info_plist | sudo tee ${file_path} 1>/dev/null
}

# Create a 'traditional' framework from the corresponding dylib.
# This includes creating a folder for it, and inserting Info.plist
# and dylib. We also patch runpaths in the dylib to match the
# frameworks directory structure.
#
# There is no command-line tool for generating .framework
# files. By inspecting .frameworks generated through Xcode, we
# have found they are primarily a directory with a very specific
# layout. The code below generates a matching layout.
#
# See https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html
create_framework() {
    local ffmpeg_component_name="$1"
    local target_sdk="$2"

    local ffmpeg_build_path="${ffmpeg_source_dir}/build_ios/${target_sdk}/installed/${prefix}"
    local ffmpeg_component_src_dylib="${ffmpeg_build_path}/lib/${ffmpeg_component_name}.dylib"
    local ffmpeg_component_framework="${ffmpeg_build_path}/framework/${ffmpeg_component_name}.framework"
    local ffmpeg_component_target_dylib="${ffmpeg_component_framework}/${ffmpeg_component_name}"

    # Make directory for the .framework
    sudo mkdir -p "${ffmpeg_component_framework}"

    # Inser the Info.plist
    build_info_plist \
        "${ffmpeg_component_framework}/Info.plist" \
        "${ffmpeg_component_name}" \
        "io.qt.ffmpegkit.${ffmpeg_component_name}"

    # Copy in the dylib
    sudo cp \
        "${ffmpeg_component_src_dylib}" \
        "${ffmpeg_component_target_dylib}"

    # By default, runpaths will look for FFmpeg dependencies in
    # '@rpath/libavcodec.xx.yy.dylib'. We want this path to be in the form
    # '@rpath/libavcodec.framework/libavcodec.dylib'.

    # Set the dylibs self-identity
    sudo install_name_tool \
        -id "@rpath/${ffmpeg_component_name}.framework/${ffmpeg_component_name}" \
        "${ffmpeg_component_target_dylib}"

    # Update the runpaths for each FFmpeg dependency entry. The dylib may be
    # universal, in which case otool lists the dependencies once per
    # architecture, each list preceded by an unindented header line.
    otool -L "$ffmpeg_component_target_dylib" \
        | awk '/^[[:space:]]/ {print $1}' \
        | sort -u \
        | while read -r dep; do
            # Go through all dependency entries of this .dylib,
            # see if they point to a FFmpeg component. If it does,
            # modify the entry to match the final
            # directory structure.
            for ffdep in $ffmpeg_components; do
                if [[ "$dep" == */${ffdep}.* ]]; then
                    echo "Rewriting dependency: $dep -> @rpath/${ffdep}.framework/${ffdep}"
                    sudo install_name_tool -change \
                        "$dep" \
                        "@rpath/${ffdep}.framework/${ffdep}" \
                        "$ffmpeg_component_target_dylib"
                fi
            done
        done
}

# dSYM symbols must be generated manually, these are required for
# App Store deployment. We generate them from the .dylibs inside
# our .frameworks. This has to be done after patching the runpaths.
# At the end, we strip the dylib.
create_dsym() {
    local ffmpeg_component_name="$1"
    local target_sdk="$2"

    local ffmpeg_build_path="${ffmpeg_source_dir}/build_ios/${target_sdk}/installed/${prefix}"
    local target_dylib="${ffmpeg_build_path}/framework/${ffmpeg_component_name}.framework/${ffmpeg_component_name}"

    sudo dsymutil "${target_dylib}" \
        -o "${ffmpeg_build_path}/framework/${ffmpeg_component_name}.framework.dSYM"

    local strip;
    strip="$(xcrun -f --sdk ${target_sdk} strip)"
    sudo ${strip} -x "${target_dylib}"
}

# Create an .xcframework from the given component's framework and dSYM
# for each target SDK.
create_xcframework() {
    local framework_name="$1"
    shift

    local xcframework_args=()
    local target_sdk
    for target_sdk in "$@"; do
        local sdk_build="${ffmpeg_source_dir}/build_ios/${target_sdk}/installed/${prefix}"
        local fw="${sdk_build}/framework/${framework_name}.framework"
        xcframework_args+=(-framework "$fw" -debug-symbols "${fw}.dSYM")
    done

    sudo mkdir -p "$prefix/lib/"
    sudo xcodebuild -create-xcframework \
        "${xcframework_args[@]}" \
        -output "${prefix}/lib/${framework_name}.xcframework"
}

# Build for each chosen ABI
for target_platform in "${target_platforms[@]}"; do
    build_ffmpeg_ios "$target_platform"
done

# Combine the ABIs of each SDK into universal dylibs
for target_sdk in "${target_sdks[@]}"; do
    lipo_dylibs "$target_sdk"
done

# Create .frameworks and dSYMs for each FFmpeg component, for each SDK
for name in $ffmpeg_components; do
    for target_sdk in "${target_sdks[@]}"; do
        create_framework "$name" "$target_sdk"
        create_dsym "$name" "$target_sdk"
    done
done

# Create corresponding xcframeworks containing the frameworks of all target SDKs:
for name in $ffmpeg_components; do
    create_xcframework "$name" "${target_sdks[@]}"
done

# xcframeworks are already installed directly into the target output directory.
# We need to install headers. These are the same for all target platforms,
# so we take them from the first one.
sudo cp -r "${ffmpeg_source_dir}/build_ios/${target_platforms[0]}/installed/${prefix}/include" "$prefix"

if [ "$skip_env_var" == "no" ]; then
    set_ffmpeg_dir_env_var "FFMPEG_DIR_IOS" "$prefix"
fi
