# This is needed e.g. for Android NDK installation for Windows 7 x86
Write-Host "Increase value of MaxMemoryPerShellMB to avoid 'out of memory' exception"
set-item wsman:localhost\Shell\MaxMemoryPerShellMB 2048
