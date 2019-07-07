. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir, [switch]$overwriteUserGitconfig) {
    $content = "[include]`n    path = $($scoopdir.Replace("\", "/") )/persist/git/.gitconfig`n"
    EnsureFileContent -Path "~\.gitconfig" -Content $content -Force:$overwriteUserGitconfig  -AllowForceHelpMessage "To allow overwrite, set 'overwriteUserGitconfig' option to 'true' in $env:SCOOP\persist\sboot\config\ScoopConfig.json"
}

Function AppUninstalled {
}
