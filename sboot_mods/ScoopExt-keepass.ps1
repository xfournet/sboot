. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    FileTypeDefine -Type "kdbxfile" -Label "KeePass Database" -Command """$AppDir\KeePass.exe"" ""%1""" -CommandLabel "&Open with KeePass" -Icon "$AppDir\KeePass.exe,0"
    FileExtAssociate -Ext "kdbx" -FileType "kdbxfile"
}

Function AppUninstalled {
    FileExtAssociate -Ext "kdbx" -FileType $null -IfFileType "kdbxfile"
    FileTypeUndefine -Type "kdbxfile"
}