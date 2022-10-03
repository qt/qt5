$x_value = "1280"
$y_value = "800"

Function ChangeResolution {
    Param (
        [string]$driver
    )

    $path = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"

    reg.exe ADD "$path\$driver\00\" /V PrimSurfSize.cx /T REG_dWORD /D $x_value /F
    reg.exe ADD "$path\$driver\00\" /V PrimSurfSize.cy /T REG_dWORD /D $y_value /F
    reg.exe ADD "$path\$driver\00\00" /V DwmClipBox.bottom /T REG_dWORD /D $y_value /F
    reg.exe ADD "$path\$driver\00\00" /V DwmClipBox.right /T REG_dWORD /D $x_value /F
    reg.exe ADD "$path\$driver\00\00" /V PrimSurfSize.cx /T REG_dWORD /D $x_value /F
    reg.exe ADD "$path\$driver\00\00" /V PrimSurfSize.cy /T REG_dWORD /D $y_value /F
    reg.exe ADD "$path\$driver\00\00" /V ActiveSize.cy /T REG_dWORD /D $y_value /F
    reg.exe ADD "$path\$driver\00\00" /V ActiveSize.cx /T REG_dWORD /D $x_value /F

}

Write-Host "Changing the resolution to ${x_value}x${y_value}"
ChangeResolution "MSBDD_NOEDID_1234_1111_00000000_00020000_0^E3701873EC28AFCFF631E725354CDC2D"
ChangeResolution "MSBDD_NOEDID_15AD_0405_00000000_000F0000_0^C13AE38966E73205F75BFACA84EB83A5"
ChangeResolution "MSNILNOEDID_1414_008D_FFFFFFFF_FFFFFFFF_0^030B4FCE00727AC1593E5B6FD18648D6"
