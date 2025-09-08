#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
\$piuparts_opts = ['--schroot', 'stable-amd64-sbuild', '--no-eatmydata'];
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

# For debian repo we need to update the bookworm release pgp key
mkdir -p /home/qt/.debian_key_ring
wget https://ftp-master.debian.org/keys/archive-key-12.asc -O /home/qt/.debian_key_ring/archive-key-12.asc
gpg --no-default-keyring --keyring=/home/qt/.debian_key_ring/debian_chroot.gpg --import /home/qt/.debian_key_ring/archive-key-12.asc

# Create chroot
sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates bookworm /srv/chroot/stable-amd64 http://deb.debian.org/debian --keyring=/home/qt/.debian_key_ring/debian_chroot.gpg

# For ubuntu 22.04
echo "Create chroot for Ubuntu Jammy"
## ccache can't be found with Jammy
sudo sbuild-createchroot --include=eatmydata,gnupg,ca-certificates jammy /srv/chroot/jammy-amd64 http://archive.ubuntu.com/ubuntu/
echo "Done creating chroot for Ubuntu Jammy"

# Update chroot.
sudo sbuild-update -udcar bookworm





