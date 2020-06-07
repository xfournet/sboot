$sboot_load_profiles_timing = @()
Get-ChildItem -Filter "*.ps1" "$PSScriptRoot\..\profile" | ForEach-Object {
    $stopwatch = New-Object System.Diagnostics.Stopwatch
    $stopwatch.Start()
    . $_.FullName
    $stopwatch.Stop()
    $sboot_load_profiles_timing += "Profile $( $_.Name ) took $( $stopwatch.ElapsedMilliseconds ) ms"
}
