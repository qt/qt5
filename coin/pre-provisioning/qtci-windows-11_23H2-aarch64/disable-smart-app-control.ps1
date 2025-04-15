# Disable Smart app control
# Smart app control makes installations extremely slow after defender is disabled.
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /V VerifiedAndReputablePolicyState /T REG_dWORD /D 0 /F
# Verify: Settings -> Privacy & security -> Windows security -> App & browser control -> Smart App Control settings -> Off
