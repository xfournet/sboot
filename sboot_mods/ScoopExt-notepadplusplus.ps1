. "$( sboot_mod "ScoopMod" )"

Function EnsureNotepadplusplusConfiguration {
    $count = GetUpdateCount

    $isInstalled = ScoopIsInstalled "notepadplusplus"
    if ($isInstalled) {
        $notepadplusplusPath = scoop prefix "notepadplusplus"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++" -Name "" -Type String -Value "Edit with &Notepad++"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++" -Name "icon" -Type String  -Value """$notepadplusplusPath\notepad++.exe"""
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++\command" -Name "" -Type String -Value """$notepadplusplusPath\notepad++.exe"" ""%1"""
    } else {
        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++"
    }

    $count = (GetUpdateCount) - $count
    if ($count) {
        IncrementGlobalAssociationChangedCounter
    }
}
