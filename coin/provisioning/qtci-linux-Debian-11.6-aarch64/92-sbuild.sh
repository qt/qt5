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
sudo sbuild-adduser $LOGNAME
newgrp sbuild

# Create chroot
#sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates stable /srv/chroot/stable-arm64-sbuild http://127.0.0.1:3142/deb.debian.org/debian
sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates stable /srv/chroot/stable-arm64-sbuild

# Update chroot
sudo sbuild-update -udcar stable






