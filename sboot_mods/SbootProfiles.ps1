. "$( sboot_mod "Utils" )"

if (!(Test-Path $PROFILE)) {
    $profileDir = Split-Path $PROFILE
    DoUpdate -RequireAdmin "Creating default user profile powershell file" {
        if (!(Test-Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory | Out-Null
        }

        '' > $PROFILE
    }

    $text = &{If(Test-Path -Path $Profile) {(Get-Content $PROFILE)} Else {""}}

    if ($null -eq ($text | Select-String '#sboot-profiles')) {
        DoUpdate -RequireAdmin "Add sboot-profiles to user profile powershell file" {
            # read and write whole profile to avoid problems with line endings and encodings
            $new_profile = @($text) + "#sboot-profiles" + '. "$env:SCOOP\apps\sboot\current\bin\load-profiles.ps1"'
            $new_profile > $PROFILE
        }
    }
}
