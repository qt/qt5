# Windows 'Notifications & actions'
# Disable 'Get notifications from apps and other senders'
reg.exe ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /V ToastEnabled /T REG_dWORD /D 0 /F

# Disable 'Show me the Windows welcome experience after udpates and occasionally when I sign in to highlight what's new and suggested'
reg.exe ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /V SubscribedContent-310093Enabled /T REG_dWORD /D 0 /F

# Disable 'Get tips, tricks and suggestions as you use Windows'
reg.exe ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /V SubscribedContent-338389Enabled /T REG_dWORD /D 0 /F
