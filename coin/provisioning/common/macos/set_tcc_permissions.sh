#!/usr/bin/env bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

TCC_DATABASE="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
if touch "$TCC_DATABASE"; then
    # We can write to the TCC database
    BOOTSTRAP_AGENT="$HOME/bootstrap-agent"
    REQ_STR=$(codesign -d -r- "$BOOTSTRAP_AGENT" 2>&1 | awk -F ' => ' '/designated/{print $2}')
    REQ_HEX=$(echo "$REQ_STR" | csreq -r- -b >(xxd -p | tr -d '\n'))

    # shellcheck disable=SC2043
    for service in kTCCServiceMicrophone; do
        sqlite3 -echo "$TCC_DATABASE" <<EOF
            DELETE from access WHERE client = '$BOOTSTRAP_AGENT' AND service = '$service';
            INSERT INTO access (service, client, client_type, auth_value, auth_reason, auth_version, csreq, flags) VALUES (
              '$service', -- service
              '$BOOTSTRAP_AGENT', -- client
              1, -- client_type (1 - absolute path)
              2, -- auth_value  (2 - allowed)
              4, -- auth_reason (4 - "System Set")
              1, -- auth_version
              X'$REQ_HEX', -- csreq
              0 -- flags
            );
EOF
    done
else
    echo "TCC database is not writable. Is SIP disabled?" >&2
    exit 1
fi
