. "$( sboot_mod "ScoopMod" )"

Function EnsureWinmergeConfiguration {
    $count = GetUpdateCount

    $isInstalled = ScoopIsInstalled "winmerge"
    if ($isInstalled) {
        $winmergePath = scoop prefix "winmerge"
        Start-Process "$winmergePath\Register.bat"
    } else {
        Start-Process "$winmergePath\UnRegister.bat"
    }

    $count = (GetUpdateCount) - $count
    if ($count) {
        IncrementGlobalAssociationChangedCounter
    }
}
