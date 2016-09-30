. "$PSScriptRoot\helpers.ps1"

$installer = "c:\users\qt\downloads\rubyinstaller-2.3.1.exe"

Download https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.3.1.exe http://ci-files01-hki.ci.local/input/ruby/rubyinstaller-2.3.1.exe $installer
Verify-Checksum $installer "FF377F6F313849C3B0CD72EEC1EFFA436F0E4A36"
& $installer /DIR=C:\ruby /VERYSILENT
