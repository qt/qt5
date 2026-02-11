#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg shared libraries.
#
# The script will package iOS and iOS-simulator binaries into one
# single .xcframework. This .xcframework cannot contain .dylibs
# directly. It must contain .framework files. Unlike macOS, binaries
# should NOT be lipoed together.
#
# From https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle
# "Avoid using dynamic library files (.dylib files) for dynamic
# linking. An XCFramework can include dynamic library files, but only
# macOS supports these libraries for dynamic linking. Dynamic linking
# on iOS, iPadOS, tvOS, visionOS, and watchOS requires the XCFramework
# to contain .framework bundles."
#
# This script can take an optional final parameter to control
# installation directory.
set -eoux pipefail

# Must match or be lower than the minimum iOS version supported by the version of Qt that is
# is currently being built.
readonly MINIMUM_IOS_VERSION="16.0"

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

ffmpeg_version=$(ffmpeg_version_default)
ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_config_options=$(get_ffmpeg_config_options "shared")
default_prefix="/usr/local/ios/ffmpeg"
prefix="${1:-$default_prefix}"

# Qt doesn't utilize all FFmpeg components. This is a list of the ones
# we care about
ffmpeg_components="libavcodec libavformat libavutil libswresample libswscale"

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

build_ffmpeg_ios() {
    local target_platform="$1"
    local target_cpu_arch=""
    local target_sdk;
    target_sdk="$(target_platform_to_sdk "${target_platform}")"

    if [ "$target_platform" == "arm64-simulator" ]; then
        target_cpu_arch="arm64"
        minos="-mios-simulator-version-min=$MINIMUM_IOS_VERSION"
    elif [ "$target_platform" == "x86_64-simulator" ]; then
        target_cpu_arch="x86_64"
        minos="-mios-simulator-version-min=$MINIMUM_IOS_VERSION"
    elif [ "$target_platform" == "arm64-iphoneos" ]; then
        target_cpu_arch="arm64"
        minos="-miphoneos-version-min=$MINIMUM_IOS_VERSION"
    else
        echo "Error when building FFmpeg for iOS. Unknown parameter given for target_platform: '${target_platform}'"
        exit 1
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
        --enable-shared
        --disable-static
        --install-name-dir="@rpath"
        --disable-audiotoolbox

        # We perform manual stripping after generating dSYMs.
        # Make sure to skip it during FFmpeg compilation.
        --disable-stripping
    )
    sudo "$ffmpeg_source_dir/configure" "${config_parameters[@]}"

    sudo make install DESTDIR="$build_dir/installed" -j4
    popd
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
    local platform="$2"

    local ffmpeg_build_path="${ffmpeg_source_dir}/build_ios/${platform}/installed/${prefix}"
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

    # Update the runpaths for each FFmpeg dependency entry
    otool -L "$ffmpeg_component_target_dylib" \
        | tail -n +2 \
        | awk '{print $1}' \
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
    local platform="$2"

    local ffmpeg_build_path="${ffmpeg_source_dir}/build_ios/${platform}/installed/${prefix}"
    local target_dylib="${ffmpeg_build_path}/framework/${ffmpeg_component_name}.framework/${ffmpeg_component_name}"

    sudo dsymutil "${target_dylib}" \
        -o "${ffmpeg_build_path}/framework/${ffmpeg_component_name}.framework.dSYM"

    local target_sdk;
    target_sdk=$(target_platform_to_sdk "${platform}")

    local strip;
    strip="$(xcrun -f --sdk ${target_sdk} strip)"
    sudo ${strip} -x "${target_dylib}"
}

create_xcframework() {
    # Create 'traditional' framework from the corresponding dylib,
    # also creating
    local framework_name="$1"
    local target_platform_a="$2"
    local target_platform_b="$3"

    local platform_a_build="${ffmpeg_source_dir}/build_ios/${target_platform_a}/installed/${prefix}"
    local fw_a="${platform_a_build}/framework/${framework_name}.framework"
    local dsym_a="${fw_a}.dSYM"

    local platform_b_build="${ffmpeg_source_dir}/build_ios/${target_platform_b}/installed/${prefix}"
    local fw_b="${platform_b_build}/framework/${framework_name}.framework"
    local dsym_b="${fw_b}.dSYM"

    sudo mkdir -p "$prefix/lib/"
    sudo xcodebuild -create-xcframework \
        -framework "$fw_a" -debug-symbols "$dsym_a" \
        -framework $fw_b -debug-symbols "$dsym_b" \
        -output "${prefix}/lib/${framework_name}.xcframework"
}

build_ffmpeg_ios "arm64-iphoneos"
build_ffmpeg_ios "x86_64-simulator"

for name in $ffmpeg_components; do
    create_framework "$name" "arm64-iphoneos"
    create_framework "$name" "x86_64-simulator"

    create_dsym "$name" "arm64-iphoneos"
    create_dsym "$name" "x86_64-simulator"
done

# Create corresponding xcframeworks containing both arm64 and x86_64-simulator frameworks:
for name in $ffmpeg_components; do
    create_xcframework "$name" "arm64-iphoneos" "x86_64-simulator"
done

# xcframeworks are already installed directly into the target output directory.
# We need to install headers
sudo cp -r "${ffmpeg_source_dir}/build_ios/arm64-iphoneos/installed/${prefix}/include" "$prefix"

set_ffmpeg_dir_env_var "FFMPEG_DIR_IOS" "$prefix"
