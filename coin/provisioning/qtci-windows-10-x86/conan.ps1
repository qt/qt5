. "$PSScriptRoot\..\common\conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-X86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14
