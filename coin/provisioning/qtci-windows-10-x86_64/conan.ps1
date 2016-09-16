. "$PSScriptRoot\..\common\conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-X86_64 `
    -Arch x86_64 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14
