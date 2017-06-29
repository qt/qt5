# Turning off win defender.
#
# If disabled manually, windows will automatically enable it after
# some period of time. Disabling it speeds up the builds.
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /V DisableAntiSpyware /T REG_dWORD /D 1 /F
