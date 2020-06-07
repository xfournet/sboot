. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    $persistSettings = "$env:SCOOP\persist\windows-terminal\settings.json"
    if (Test-Path $persistSettings) {
        EnsureLink -LinkPath "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json" -TargetPath $persistSettings
    }
}

Function AppUninstalled {
}
