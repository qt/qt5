function InstallMinGW
{
    Param (
        [string] $version     = $(BadParam("the version being printed to versions.txt")),
        [string] $release     = $(BadParam("release part of the file name"))
    )

    $envvar = "MINGW$version"
    $envvar = $envvar -replace '["."]'
    $targetdir = "C:\$envvar"
    $url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\i686-" + $version + "-" + $release + ".7z"

    $mingwPackage = "C:\Windows\Temp\MinGW-$version.zip"
    Copy-Item $url_cache $mingwPackage

    Get-ChildItem $mingwPackage | % {& "C:\Utils\sevenzip\7z.exe" "x" $_.fullname "-o$TARGETDIR"}

    echo "Adding MinGW environment variable."
    [Environment]::SetEnvironmentVariable("$envvar", "$targetdir\mingw32", [EnvironmentVariableTarget]::Machine)

    echo "Cleaning $mingwPackage.."
    Remove-Item -Recurse -Force "$mingwPackage"

    echo "MinGW = $version $release" >> ~\versions.txt

}
