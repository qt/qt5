############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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
#############################################################################

# Visual Studio $version version $version_number was installed manually using $installer.

$version = "2019"
# Current version was manually upgraded from the installer
$version_number = "16.3.2"
$installer = "http://ci-files01-hki.ci.local/input/windows/vs_professional__505064367.1547034421.exe"

.NET Framework 4.5 targeting pack
.NET Framework 4.5.1 targeting pack
.NET Framework 4.5.2 targeting pack
.NET Framework 4.6.1 SDK
.NET Framework 4.6.1 targeting pack
.NET Framework 4.6.2 SDK
.NET Framework 4.6.2 targeting pack
.NET Framework 4.7.2 SDK
.NET Framework 4.7.2 targeting pack
.NET Native
.NET Portable Library targeting pack
CLR data typer for SQL Sever
Connectivity and publishing tools
Data sources for SQL Server support
SQL ADAL runtime
SQL Server Command Linne Utilities
SQL Server Data Tools
SQL Server Express 2016 LocalDB
SQL Server ODBC Driver
ClickOnce Publishing
Developer Analytics tools
NuGet package manager
Text Template Transformation
C# and Visual Basic Roslyn compilers
C++ 2019 Redistributable Update
C++ Cmake tools for Windows
C++/CLI support for v142 build tools
MSBuild
MSVC v142 - VS 2019 C++ ARM build tools (v14.20)
MSVC v142 - VS 2019 C++ ARM64 build tools (v14.20)
MSVC v142 - VS 2019 C++ x64/x86 build tools (v14.20)
.NET profiling tools
C++ profiling tools
JavaScript diagnostics
Just-In-Time debugger
C# and Visual Basic
C++ core features
JavaSript and TypeScript language support
Razor Language Services
Graphics debugger and GPU profiler for DirectX
Image and 3D model editors
C++ ATL for v142 build tools (x86 & x64)
TypeScript 3.3 SDK
Windows 10 SDK (10.0.16299.0)
Windows 10 SDK (10.0.17134.0)
Windows 10 SDK (10.0.17763.0)
Windows 10 SDK (10.0.18362.0)

# NOTE! Work loads were added during installation!

echo "Visual Studio = $version version version_number" >> ~\versions.txt
