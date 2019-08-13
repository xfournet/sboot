. "$( sboot_mod "Utils" )"

Function AppInstalled([String]$AppDir) {
    # keystore-explore required to have a jre directory in it's application directory in order to start
    $kseJreDir = "$AppDir\jre"
    $javaHome = Split-Path -Parent (Split-Path -Parent (Get-Command java.exe).Path)
    if ($javaHome) {
        EnsureJunction -JunctionPath $kseJreDir -TargetPath $javaHome
    } else {
        LogWarn "java.exe has not be found in PATH"
    }
}

Function AppUninstalled {
}
