sboot_cfg -Name "Win10Settings"

sboot_cfg -Name "ScoopConfig" -Default -Script {
    . "$( sboot_mod "ScoopMod" )"
    EnsureScoopConfig -ScoopConfig (Get-Content "$PSScriptRoot\ScoopConfig.json")
}

sboot_cfg -Name "EnvVars" -Default

sboot_cfg -Name "SbootProfiles" -Default -Script {
    . "$( sboot_mod "SbootProfiles" )"
    EnsurePowershellProfileConfiguration
}
