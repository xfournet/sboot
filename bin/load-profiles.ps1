Get-ChildItem -Filter "*.ps1" "$PSScriptRoot\..\profile" | ForEach-Object { . $_.FullName }
