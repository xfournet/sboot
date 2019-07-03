Get-ChildItem -Filter "Profile*.ps1" "$env:SCOOP\persist\profile" | ForEach-Object { . $_.FullName }
