. "$PSScriptRoot\..\common\03-conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir Mingw53-x86 `
    -Arch x86 `
    -Compiler "gcc" `
    -CompilerVersion "5.3" `
    -CompilerLibcxx "libstdc++11"
