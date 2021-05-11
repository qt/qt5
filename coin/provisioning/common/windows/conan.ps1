############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
############################################################################

. "$PSScriptRoot\helpers.ps1"

# This is temporary solution for installing packages provided by Conan until we have fixed Conan setup for this

$url_conan = "\\ci-files01-hki.intra.qt.io\provisioning\windows\.conan.zip"
$url_conan_home = "\\ci-files01-hki.intra.qt.io\provisioning\windows\.conanhome.zip"
$sha1_conan_compressed = "1abbe43e7a29ddd9906328702b5bc5231deeb721"
$sha1_conanhome_compressed = "f44c2ae21cb1c7dc139572e399b7b0eaf492af03"
$conan_compressed = "C:\.conan.zip"
$conanhome_compressed = "C:\.conanhome.zip"

Download $url_conan $url_conan $conan_compressed
Verify-Checksum $conan_compressed $sha1_conan_compressed
Extract-7Zip $conan_compressed C:\

Download $url_conan_home $url_conan_home $conanhome_compressed
Verify-Checksum $conanhome_compressed $sha1_conanhome_compressed
Extract-7Zip $conanhome_compressed C:\Users\qt

Remove $conan_compressed
Remove $conanhome_compressed
