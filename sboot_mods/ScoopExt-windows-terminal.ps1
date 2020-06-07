. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    $persistSettings = "$env:SCOOP\persist\windows-terminal\settings.json"
    if (Test-Path $persistSettings) {
        EnsureLink -LinkPath "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json" -TargetPath $persistSettings
    }

    # Temporary fix of windows-terminal icons, waiting for https://github.com/lukesampson/scoop-extras/pull/4233 to be integrated
    Get-ChildItem "$AppDir\\ProfileIcons" '*.png' | ForEach-Object {
        $currentName = $_.Name
        $newName = $_.Name.Replace('%7B', '{').Replace('%7D', '}')
        if ($newName -ne $currentName) {
            DoUpdate "Fix Windows terminal icon name '$currentName', renamed to '$newName'" {
                $_ | Rename-Item -NewName $newName
            }
        }
    }
}

Function AppUninstalled {
}
