. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++" -Name "" -Type String -Value "Edit with &Notepad++"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++" -Name "icon" -Type String  -Value """$AppDir\notepad++.exe"""
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++\command" -Name "" -Type String -Value """$AppDir\notepad++.exe"" ""%1"""
}

Function AppUninstalled {
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\Notepad++"
}
