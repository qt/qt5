#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg static libs
# Can take an optional final parameter to control installation directory
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

build_ffmpeg_ios() {
    local target_platform=$1
    local target_cpu_arch=""
    if [ "$target_platform" == "arm64-simulator" ]; then
        target_sdk="iphonesimulator"
        target_cpu_arch="arm64"
        minos="-mios-simulator-version-min=$MINIMUM_IOS_VERSION"
    elif [ "$target_platform" == "x86_64-simulator" ]; then
        target_sdk="iphonesimulator"
        target_cpu_arch="x86_64"
        minos="-mios-simulator-version-min=$MINIMUM_IOS_VERSION"
    elif [ "$target_platform" == "arm64-iphoneos" ]; then
        target_sdk="iphoneos"
        target_cpu_arch="arm64"
        minos="-miphoneos-version-min=$MINIMUM_IOS_VERSION"
    else
        echo "Error when building FFmpeg for iOS. Unknown parameter given for target_platform: '${target_platform}'"
        exit 1
    fi

    local build_dir="$ffmpeg_source_dir/build_ios/$target_platform"
    sudo mkdir -p "$build_dir"
    pushd "$build_dir"

    # shellcheck disable=SC2086
    sudo "$ffmpeg_source_dir/configure" $ffmpeg_config_options \
    --sysroot="$(xcrun --sdk "$target_sdk" --show-sdk-path)" \
    --enable-cross-compile \
    --enable-optimizations \
    --prefix=$prefix \
    --arch=$target_cpu_arch \
    --cc="xcrun --sdk ${target_sdk} clang -arch $target_cpu_arch" \
    --cxx="xcrun --sdk ${target_sdk} clang++ -arch $target_cpu_arch" \
    --target-os=darwin \
    --extra-cflags="$minos" \
    --extra-cxxflags="$minos" \
    --extra-objcflags="$minos" \
    --extra-ldflags="$minos" \
    --enable-shared \
    --disable-static \
    --install-name-dir='@rpath' \
    --disable-audiotoolbox

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

create_xcframework() {
    # Create 'traditional' framework from the corresponding dylib,
    # also creating
    local framework_name="$1"
    local target_platform_a="$2"
    local target_platform_b="$3"

    local fw_a="$ffmpeg_source_dir/build_ios/${target_platform_a}/installed$prefix/framework/${framework_name}.framework"
    local fw_b="$ffmpeg_source_dir/build_ios/${target_platform_b}/installed$prefix/framework/${framework_name}.framework"

    sudo mkdir -p "$prefix/lib/"
    sudo xcodebuild -create-xcframework -framework $fw_a -framework $fw_b -output "${prefix}/lib/${framework_name}.xcframework"
}

build_ffmpeg_ios "arm64-iphoneos"
build_ffmpeg_ios "x86_64-simulator"

for name in $ffmpeg_components; do
    create_framework "$name" "arm64-iphoneos"
    create_framework "$name" "x86_64-simulator"
done

# Create corresponding xcframeworks containing both arm64 and x86_64-simulator frameworks:
for name in $ffmpeg_components; do
    create_xcframework "$name" "arm64-iphoneos" "x86_64-simulator"
done

# xcframeworks are already installed directly into the target output directory.
# We need to install headers
sudo cp -r "${ffmpeg_source_dir}/build_ios/arm64-iphoneos/installed${prefix}/include" "$prefix"

set_ffmpeg_dir_env_var "FFMPEG_DIR_IOS" $prefix
