. "$( sboot_mod "ScoopMod" )"

Function EnsureGitConfiguration([switch]$Force) {
    $isInstalled = ScoopIsInstalled "git"
    if ($isInstalled) {
        $content = "[include]`n    path = $($scoopdir.Replace("\", "/"))/persist/git/.gitconfig`n"
        EnsureFileContent -Path "~\.gitconfig" -Content $content -Force:$Force
    }
}