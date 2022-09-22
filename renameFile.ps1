$name = $env:username
Rename-Item "./PCinfo.txt" -NewName "PCinfo-$($name).txt"