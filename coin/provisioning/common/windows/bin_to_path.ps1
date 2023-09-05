if (-not ($env:PATH -split ';' | Where-Object { $_ -eq "C:\Program Files\Git\usr\bin" })) {
    & setx PATH "C:\Program Files\Git\usr\bin"
    Write-Host "Added C:\Program Files\Git\usr\bin to PATH."
}
