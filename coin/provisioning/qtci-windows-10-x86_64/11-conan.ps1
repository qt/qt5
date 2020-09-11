. "$PSScriptRoot\..\common\windows\conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-x86_64 `
    -Arch x86_64 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-x86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2017-x86_64 `
    -Arch x86_64 `
    -Compiler "Visual Studio" `
    -CompilerVersion 15 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2017-x86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 15 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2019-x86_64 `
    -Arch x86_64 `
    -Compiler "Visual Studio" `
    -CompilerVersion 16 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2019-x86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 16 `
    -CompilerRuntime MD

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir Mingw-x86 `
    -Arch x86 `
    -Compiler "gcc" `
    -CompilerVersion 8 `
    -CompilerLibcxx "libstdc++" `
    -CompilerException "dwarf2" `
    -CompilerThreads "posix"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir Mingw-x86_64 `
    -Arch x86_64 `
    -Compiler "gcc" `
    -CompilerVersion 8 `
    -CompilerLibcxx "libstdc++" `
    -CompilerException "seh" `
    -CompilerThreads "posix"
