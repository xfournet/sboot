. "$(sboot_mod "Utils")"

# Set EDITOR variable. Double slash to be compatible both with Windows and Unix (eg. git)
#EnsureEnvironmentVariable -Name "EDITOR" -Value "$(scoop prefix vim)\vim.exe".Replace("\", "\\")
