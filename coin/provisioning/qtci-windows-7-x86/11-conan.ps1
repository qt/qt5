. "$PSScriptRoot\..\common\windows\conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir Mingw-x86 `
    -Arch x86 `
    -Compiler "gcc" `
    -CompilerVersion 8 `
    -CompilerLibcxx "libstdc++" `
    -CompilerException "dwarf2" `
    -CompilerThreads "posix"
