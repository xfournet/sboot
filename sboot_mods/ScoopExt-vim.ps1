. "$( sboot_mod "Utils" )"

$vimCLSID = "{51EEE242-AD87-11d3-9C1E-0090278BBD99}"

Function AppInstalled([String]$AppDir, [switch]$overwriteUserVimrc) {
    $content = "source `$SCOOP/persist/vim/vimrc.vim`n"
    EnsureFileContent -Path "~\_vimrc" -Content $content -Force:$overwriteUserVimrc -AllowForceHelpMessage "To allow overwrite, set 'overwriteUserVimrc' option to 'true' in $env:SCOOP\persist\sboot\config\ScoopConfig.json"

    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim" -Name "path" -Type String -Value "$AppDir\gvim.exe"
    EnsureShellExtensionRegistered -CLSID $vimCLSID -Label "Vim Shell Extension" -DLL64Path "$AppDir\GvimExt64\gvimext.dll" -DLL32Path "$AppDir\GvimExt32\gvimext.dll"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim" -Name "" -Type String -Value "$vimCLSID"
}

Function AppUninstalled {
    EnsureRegistryKeyDeleted -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim"
    EnsureShellExtensionUnregistered -CLSID $vimCLSID
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\gvim"
}
