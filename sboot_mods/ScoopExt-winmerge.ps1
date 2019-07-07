. "$( sboot_mod "Utils" )"

$wimMergeCLSID = "{4E716236-AA30-4C65-B225-D68BBA81E9C2}"

Function AppInstalled([String]$AppDir) {
    EnsureShellExtensionRegistered -CLSID $wimMergeCLSID -Label "WinMergeShell Class" -DLL64Path "$AppDir\ShellExtensionX64.dll" -DLL32Path "$AppDir\ShellExtensionU.dll"

    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\Background\shellex\DragDropHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\WinMerge" -Name "" -Type String -Value "$wimMergeCLSID"

    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Thingamahoochie\WinMerge" -Name "ContextMenuEnabled" -Type DWORD -Value 3
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Thingamahoochie\WinMerge" -Name "Executable" -Type String -Value "$AppDir\WinMergeU.exe"
}

Function AppUninstalled {
    EnsureShellExtensionUnregistered -CLSID $wimMergeCLSID

    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\Background\shellex\DragDropHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\WinMerge"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\WinMerge"

    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Thingamahoochie\WinMerge" -Name "ContextMenuEnabled" -Type DWORD -Value $null
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Thingamahoochie\WinMerge" -Name "Executable" -Type String -Value $null
}
