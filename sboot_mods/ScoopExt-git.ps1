. "$( sboot_mod "ScoopMod" )"

Function EnsureGitConfiguration {
    $isInstalled = ScoopIsInstalled "git"
    if ($isInstalled) {
        "[include]`n    path = $($scoopdir.Replace("\", "/"))/persist/git/.gitconfig`n" | Out-File -FilePath "$env:USERPROFILE\.gitconfig" -Encoding ASCII -NoNewline
    }
}