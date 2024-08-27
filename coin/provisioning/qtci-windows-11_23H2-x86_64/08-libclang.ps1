# Do not set the default LLVM_INSTALL_DIR for mingw, leave it with msvc for compat
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 llvm-mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 vs2019
