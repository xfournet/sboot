. "$( sboot_mod "ScoopMod" )"

Function EnsureHxdConfiguration {
    $count = GetUpdateCount

    $isInstalled = ScoopIsInstalled "hxd"
    if ($isInstalled) {
        $hxdPath = scoop prefix "hxd"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxD" -Name "" -Type String -Value "Open with &HxD"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxD\command" -Name "" -Type String -Value """$hxdPath\HxD.exe"" ""%1"""

        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly" -Name "" -Type String -Value "Open with H&xD (readonly)"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly\command" -Name "" -Type String -Value """$hxdPath\HxD.exe"" /readonly ""%1"""
    } else {
        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\HxD"
        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly"
    }

    $count = (GetUpdateCount) - $count
    if ($count) {
        IncrementGlobalAssociationChangedCounter
    }
}
