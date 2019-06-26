. "$( sboot_mod "ScoopMod" )"

Function EnsureVimConfiguration {
    $count = GetUpdateCount

    $clsid = "{51EEE242-AD87-11d3-9C1E-0090278BBD99}"
    $isInstalled = ScoopIsInstalled "vim"
    if ($isInstalled) {
        $vimPath = scoop prefix "vim"
        EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim" -Name "path" -Type String -Value "$vimPath\gvim.exe"

        EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value "Vim Shell Extension"
        EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value "Vim Shell Extension"

        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid" -Name "" -Type String -Value "Vim Shell Extension"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid\InprocServer32" -Name "" -Type String -Value "$vimPath\GvimExt64\gvimext.dll"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"

        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid" -Name "" -Type String -Value "Vim Shell Extension"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid\InprocServer32" -Name "" -Type String -Value "$vimPath\GvimExt32\gvimext.dll"
        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"

        EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim" -Name "" -Type String -Value "$clsid"
    } else {
        EnsureRegistryKeyDeleted -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim"

        EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null
        EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null

        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\CLSID\$clsid"

        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid"

        EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim"
    }

    $count = (GetUpdateCount) - $count
    if ($count) {
        IncrementGlobalAssociationChangedCounter
    }
}
