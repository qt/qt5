$existingPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
if ($existingPath -notlike "*C:\Program Files\Git\usr\bin*") {
    $newPath = $existingPath + ";C:\Program Files\Git\usr\bin"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Added C:\Program Files\Git\usr\bin to PATH."
}
