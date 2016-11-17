. "$PSScriptRoot\..\common\03-conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir MSVC2015-x86_64 `
    -Arch x86_64 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14 `
    -CompilerRuntime MD
