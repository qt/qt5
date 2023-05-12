#!/bin/bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install screenresolution and set correct resolution at boot

brew install screenresolution

sudo tee -a /usr/local/bin/set_resolution.sh <<"EOF"
#!/bin/bash
sleep 20
/usr/local/bin/screenresolution set 1280x800x32@0
EOF


sudo chmod a+x /usr/local/bin/set_resolution.sh


sudo tee -a ~/Library/LaunchAgents/screenresolution.plist <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple/DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>org.qt.io.screenresolution</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/bin/set_resolution.sh</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>LaunchOnlyOnce</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>/tmp/screenresolution.err</string>
        <key>StandardOutPath</key>
        <string>/tmp/screenresolution.out</string>
    </dict>
</plist>
EOF

