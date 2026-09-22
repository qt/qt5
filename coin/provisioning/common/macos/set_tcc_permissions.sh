#!/usr/bin/env bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

# ------ Clients ------

TCC_CLIENTS=()

# The original path to bootstrap-agent
if [[ -x "$HOME/bootstrap-agent" ]]; then
    TCC_CLIENTS+=("$HOME/bootstrap-agent")
fi

# The app-bundle version of the agent, in case we install it like that
if [[ -d "$HOME/bootstrap-agent.app" ]]; then
    TCC_CLIENTS+=("$HOME/bootstrap-agent.app")
fi

# The responsible process for the SSH server. By giving this
# process the permissions we ensure that developers SSH'ing
# into a CI machine will have the same permissions when running
# tests as bootstrap-agent has. This also opens the door to
# running the boostrap agent via SSH, giving the exact same
# environment for interactive developer sessions as coin.
TCC_CLIENTS+=("/usr/libexec/sshd-keygen-wrapper")

# ------ Services (permissions) ------

SERVICES=()

# Qt Multimedia tests need microphone access
SERVICES+=("kTCCServiceMicrophone|user")

# Qt Connectivity tests need Bluetooth access
SERVICES+=("kTCCServiceBluetoothAlways|user")

# Qt Multimedia might need screen capture, and it can
# also be useful for capturing the state of the VM when
# a test fails.
SERVICES+=("kTCCServiceScreenCapture|system")

# Squish requires kTCCServiceAccessibility
SERVICES+=("kTCCServiceAccessibility|system")

# ------ Implementation ------

# Starting with macOS 27, tccd's per-user database moved out of
# ~/Library/Application Support/com.apple.TCC into a randomly named
# container under ProtectedSystem. The container UUID is assigned by
# containermanagerd and isn't derived from anything we can compute, so
# look it up by identifier instead. The system-wide database (owned by
# "tccd system", running as root) is unaffected and stays where it was.
function find_tccd_container() {
    local plist
    for plist in /private/var/containers/Data/ProtectedSystem/*/.com.apple.containermanagerd.metadata.plist; do
        if [[ "$(sudo defaults read "$plist" MCMMetadataIdentifier 2>/dev/null)" == "com.apple.tccd" ]]; then
            dirname "$plist"
            return 0
        fi
    done
    return 1
}

function is_macos_27_or_later() {
    local version
    version=$(sw_vers -productVersion)
    (( ${version%%.*} >= 27 ))
}

# Resolve both database locations once, up front, instead of on every
# add_permission_for_client call. The user one in particular requires
# walking ProtectedSystem containers on macOS 27+, which is wasteful
# to repeat for each client/service pair.
SYSTEM_TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
if is_macos_27_or_later; then
    tccd_container=$(find_tccd_container) || {
        echo "Could not locate tccd's ProtectedSystem container" >&2
        exit 1
    }
    USER_TCC_DB="$tccd_container/Data/Library/Application Support/com.apple.TCC/TCC.db"
else
    USER_TCC_DB="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
fi

function add_permission_for_client() {
    local client="$1"
    local service="$2"

    local scope="${service#*|}"
    local service="${service%|*}"

    local tcc_database
    if [[ "$scope" == "system" ]]; then
        tcc_database="$SYSTEM_TCC_DB"
    else
        tcc_database="$USER_TCC_DB"
    fi
    if ! sudo touch "$tcc_database"; then
        echo "TCC database is not writable. Is SIP disabled?" >&2
        exit 1
    fi

    if [[ -d "$client" && "${client%/}" == *.app ]]; then
        info_plist="$client/Contents/Info.plist"
        executable=$(defaults read "$info_plist" CFBundleExecutable)
        executable="$client/Contents/MacOS/$executable"
        client=$(defaults read "$info_plist" CFBundleIdentifier)
        client_type="0" # Bundle ID
    elif [[ -x "$client" ]]; then
        executable=$client
        client_type="1" # Absolute path
    else
        echo "Unknown or missing TCC client type '$client'!" >&2
        exit 1
    fi

    # shellcheck disable=SC2155
    local req_str=$(codesign -d -r- "$executable" 2>&1 | awk -F ' => ' '/designated/{print $2}')
    # shellcheck disable=SC2155
    local req_hex=$(echo "$req_str" | csreq -r- -b >(xxd -p | tr -d '\n'))

    sudo sqlite3 -echo "$tcc_database" <<EOF
        PRAGMA busy_timeout = 5000;
        DELETE from access WHERE client = '$client' AND service = '$service';
        INSERT INTO access (service, client, client_type, auth_value, auth_reason, auth_version, csreq, flags) VALUES (
          '$service', -- service
          '$client', -- client
          $client_type, -- client_type
          2, -- auth_value  (2 - allowed)
          4, -- auth_reason (4 - "System Set")
          1, -- auth_version
          X'$req_hex', -- csreq
          0 -- flags
        );
EOF

    if [[ "$service" == "kTCCServiceScreenCapture" ]]; then
        # macOS 15 will nag the user every month about applications
        # that are permitted to capture the screen. We don't want this
        # popup to come in the way of tests, so we manually extend
        # the permission.
        replayd_dir="$HOME/Library/Group Containers/group.com.apple.replayd"
        mkdir -p "$replayd_dir"
        approvals_file="$replayd_dir/ScreenCaptureApprovals.plist"
        if [[ ! -f $approvals_file ]]; then
            plutil -create xml1 "$approvals_file"
        fi
        key=${executable//\./\\.}
        plutil -replace "$key" -date "2100-01-01T00:00:00Z" "$approvals_file"
    fi
}

# shellcheck disable=SC2043
for client in "${TCC_CLIENTS[@]}"; do
    # shellcheck disable=SC2043
    for service in "${SERVICES[@]}"; do
        add_permission_for_client "$client" "$service"
    done
done
