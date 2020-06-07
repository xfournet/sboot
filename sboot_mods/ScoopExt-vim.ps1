. "$( sboot_mod "Utils" )"

$vimCLSID = "{51EEE242-AD87-11d3-9C1E-0090278BBD99}"

Function AppInstalled([String]$AppDir) {
    # Temporary fix of vim shell integration dll, waiting for https://github.com/ScoopInstaller/Main/pull/1155 to be integrated
    if (Test-Path "$AppDir\GvimExt64\`$R0") {
        DoUpdate "Fix VIM 64bit shell integration" {
            Move-Item "$AppDir\GvimExt64\`$R0" "$AppDir\GvimExt64\gvimext.dll"
            Move-Item "$AppDir\GvimExt64\`$0\GvimExt64\*" "$AppDir\GvimExt64"
            Remove-Item "$AppDir\GvimExt64\`$0" -Recurse
        }
    }
    if (Test-Path "$AppDir\GvimExt32") {
        DoUpdate "Remove broken VIM 32bit shell integration" {
            Remove-Item "$AppDir\GvimExt32" -Recurse
        }
    }

    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim" -Name "path" -Type String -Value "$AppDir\gvim.exe"
    EnsureShellExtensionRegistered -CLSID $vimCLSID -Label "Vim Shell Extension" -DLL64Path "$AppDir\GvimExt64\gvimext.dll" -DLL32Path "$AppDir\GvimExt32\gvimext.dll"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim" -Name "" -Type String -Value "$vimCLSID"
}

Function AppUninstalled {
    EnsureRegistryKeyDeleted -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim"
    EnsureShellExtensionUnregistered -CLSID $vimCLSID
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim"
}
