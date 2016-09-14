. "$PSScriptRoot\..\common\conan.ps1"

Run-Conan-Install `
    -ConanfilesDir "$PSScriptRoot\conanfiles" `
    -BuildinfoDir msvc-2015-x86 `
    -Arch x86 `
    -Compiler "Visual Studio" `
    -CompilerVersion 14
