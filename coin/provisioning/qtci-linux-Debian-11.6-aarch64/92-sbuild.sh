#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Setups sbuild environment

tee ~/.sbuildrc << EOF
##############################################################################
# PACKAGE BUILD RELATED (additionally produce _source.changes)
##############################################################################
# -d
\$distribution = 'stable';
# -A
\$build_arch_all = 1;
# -s
\$build_source = 1;
# -v
\$verbose = 1;
# parallel build
\$ENV{'DEB_BUILD_OPTIONS'} = 'parallel=8';
##############################################################################
# POST-BUILD RELATED (turn off functionality by setting variables to 0)
##############################################################################
\$run_lintian = 1;
\$lintian_opts = ['-i', '-I'];
\$run_piuparts = 0;
\$piuparts_opts = ['--schroot', 'stable-arm64-sbuild', '--no-eatmydata'];
\$run_autopkgtest = 0;
\$autopkgtest_root_args = '';
\$autopkgtest_opts = [ '--', 'schroot', '%r-%a-sbuild' ];

##############################################################################
# PERL MAGIC
##############################################################################
1;
EOF

# Add user group
sudo sbuild-adduser "$LOGNAME"
newgrp sbuild

# Create chroot for debian bookworm
sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates bookworm /srv/chroot/stable-arm64

echo "Create chroot for Ubuntu Jammy"
# First we need update the deboostrap scripts
mkdir -p "$HOME"/deboot
cd "$HOME"/deboot
# Orig url http://ftp.fi.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.134~bpo12+1.tar.gz
# we have to update the debootstrap so that sbuild-createroot will recognize jammy code name
wget http://ci-files01-hki.ci.qt.io/input/debian/debootstrap/debootstrap_1.0.134~bpo12+1.tar.gz
tar xzvf debootstrap_1.0.134~bpo12+1.tar.gz
cd debootstrap
sudo make install
cd
rm -rf "$HOME"/deboot
sudo sbuild-createchroot --include=gnupg,ca-certificates jammy /srv/chroot/jammy-arm64 http://ports.ubuntu.com/ubuntu-ports/
echo "Done creating chroot for Ubuntu Jammy"

# Update chroot.
sudo sbuild-update -udcar bookworm
sudo sbuild-update -udcar jammy
