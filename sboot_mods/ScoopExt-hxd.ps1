. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxD" -Name "" -Type String -Value "Open with &HxD"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxD" -Name "icon" -Type String  -Value """$AppDir\HxD.exe"""
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxD\command" -Name "" -Type String -Value """$AppDir\HxD.exe"" ""%1"""

    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly" -Name "" -Type String -Value "Open with H&xD (readonly)"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly" -Name "icon" -Type String  -Value """$AppDir\HxD.exe"""
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly\command" -Name "" -Type String -Value """$AppDir\HxD.exe"" /readonly ""%1"""
}

Function AppUninstalled {
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\HxD"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shell\HxDReadonly"
}
