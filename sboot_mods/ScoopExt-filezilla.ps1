. "$( sboot_mod "Utils" )"

# to be deleted when https://github.com/lukesampson/scoop-extras/pull/2425 (or equivalent) will be merged
Function AppInstalled([String]$AppDir) {
    $persistDir = "$($env:SCOOP)\persist\filezilla"

    EnsureDirectoryExist "$persistDir\config"
    EnsureJunction -JunctionPath "$AppDir\config" -TargetPath "$persistDir\config"
    EnsureFileDeleted "$persistDir\fzdefaults.xml"
    EnsureFileContent -Path "$AppDir\fzdefaults.xml" -Force -Content @"
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<FileZilla3>
  <Settings>
    <Setting name="Config Location">config</Setting>
    <Setting name="Disable update check">1</Setting>
  </Settings>
</FileZilla3>

"@
}

Function AppUninstalled {
}
