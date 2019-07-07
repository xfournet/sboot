. "$( sboot_mod "Utils" )"

Function EnsurePowershellProfileConfiguration {
    if (Test-Path -LiteralPath $PROFILE) {
        $text = Get-Content $PROFILE
    } else {
        DoUpdate -RequireAdmin "Creating default user profile PowerShell file: $PROFILE" {
            New-Item -Path $PROFILE -Force | Out-Null
        }
        $text = ""
    }

    if ($text | Select-String '#sboot-profiles') {
        LogIdempotent "sboot-profiles is already configured into user profile PowerShell file: $PROFILE"
    } else {
        DoUpdate -RequireAdmin "Add sboot-profiles to user profile PowerShell file: $PROFILE" {
            # read and write whole profile to avoid problems with line endings and encodings
            $new_profile = @($text) + "#sboot-profiles" + '. "$env:SCOOP\apps\sboot\current\bin\load-profiles.ps1"'
            $new_profile > $PROFILE
        }
    }
}
