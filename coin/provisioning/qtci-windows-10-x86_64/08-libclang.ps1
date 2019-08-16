# Do not set the default LLVM_INSTALL_DIR for mingw, leave it with msvc for compat
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" 64 vs2019
. "$PSScriptRoot\..\common\windows\libclang.ps1" 32 mingw $False
. "$PSScriptRoot\..\common\windows\libclang.ps1" 32 vs2019
