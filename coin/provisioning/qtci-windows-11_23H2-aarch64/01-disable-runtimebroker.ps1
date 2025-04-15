# Disable RunTime Broker
# The RunTime Broker is a Windows system process, which helps to manage app permissions on your pc between Windows apps and ensures apps are behaving themselves.
# Coordinates execution of background work for WinRT application. If this service is stopped or disabled, then background work might not be triggered.
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TimeBrokerSvc" /V Start /T REG_dWORD /D 4 /F
