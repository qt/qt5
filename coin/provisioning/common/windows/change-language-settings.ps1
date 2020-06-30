Write-Host "Change locale and language settings"
Set-WinSystemLocale -SystemLocale en-US
Set-WinUILanguageOverride -Language en-US
Set-WinUserLanguageList en-US -Force
