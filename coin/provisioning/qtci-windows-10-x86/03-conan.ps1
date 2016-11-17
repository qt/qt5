. "$PSScriptRoot\..\common\03-conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-x86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14 `
    -CompilerRuntime MD
