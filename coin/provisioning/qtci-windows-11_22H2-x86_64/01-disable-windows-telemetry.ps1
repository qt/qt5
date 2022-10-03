# Disable Connected User Experiences and Telemetry service
# The Connected User Experiences and Telemetry service enables features that support in-application and connected user experiences.
# Additionally, this service manages the event driven collection and transmission of diagnostic and usage information
# (used to improve the experience and quality of the Windows Platform) when the diagnostics and usage privacy option settings are enabled under Feedback and Diagnostics.
reg.exe ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Data Collection" /V AllowTelemetry /T REG_dWORD /D 0 /F
stop-service diagtrack
set-service diagtrack -startuptype disabled
