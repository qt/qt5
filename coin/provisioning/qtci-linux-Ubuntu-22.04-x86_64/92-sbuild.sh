#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

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
sudo sbuild-adduser $LOGNAME
newgrp sbuild

# Create chroot
sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates stable /srv/chroot/stable-amd64
# For ubuntu 20.04
echo "Create chroot for Ubuntu Focal"
sudo sbuild-createchroot --include=eatmydata,ccache,gnupg,ca-certificates focal /srv/chroot/focal-amd64 http://archive.ubuntu.com/ubuntu/
echo "Done creating chroot for Ubuntu Focal"

# Update chroot
sudo sbuild-update -udcar stable
sudo sbuild-update -udcar focal





