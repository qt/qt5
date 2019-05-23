# Disable Hyper-V from Windows 10 Pro/Enterprise
# Because VirtualBox is a type 2 hypervisor, it can't run if Hyper-V virtual machines are in use.
# Otherwise, docker-machine will complain about "VT-x is not available (VERR_VMX_NO_VMX)".
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart

. "$PSScriptRoot\..\common\windows\docker.ps1"
