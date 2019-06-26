Function IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
}

Function Restart {
    Write-Host "------------------------------------" -ForegroundColor Red
    Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
    Restart-Computer
}

Function KeyToValue($Key, $Values) {
    if (!$Values.ContainsKey($Key)) {
        throw "$Key is not recognized, should be '$( $Values.Keys -Join "' or '" )'"
    }
    return $Values[$Key]
}

Function EnsureRegistryKeyDeleted([String]$Path) {
    if (Test-Path -LiteralPath "Registry::$Path") {
        DoUpdate "Registry key $Path deleted" {
            Remove-Item -LiteralPath "Registry::$Path" -Force -Recurse | Out-Null
        }
    } else {
        LogIdempotent "Registry key $Path is already missing"
    }
}

Function EnsureRegistryValue([String]$Path, [String]$Name, [String]$Type, $Value) {
    if (!(Test-Path -LiteralPath "Registry::$Path")) {
        if ($null -eq $Value) {
            LogIdempotent "Registry item $Path\$Name is already missing"
            return
        }

        DoUpdate "Registry path $Path created" {
            New-Item -Path "Registry::$Path" -Force | Out-Null
        }
    }


    $key = Get-Item -LiteralPath "Registry::$Path" -ErrorAction:SilentlyContinue
    if ($null -ne $key) {
        try {
            $item = $key.OpenSubKey("", $true)
            $canWrite = $true
        }
        catch [System.Security.SecurityException] {
            $item = $key.OpenSubKey("", $false)
            $canWrite = $false
        }
        $currentValue = $item.GetValue($Name)

        if ($null -ne $Value) {
            if ($Value.GetType() -eq [ScriptBlock]) {
                $Value = $Value.InvokeReturnAsIs($currentValue)
            }
        }
    }
    else {
        if (IsDryRun) {
            $canWrite = $true
        } else {
            LogWarn "Registry key $Path cannot be accessed"
            return
        }
    }

    if ($currentValue -ne $Value) {
        if ($null -ne $Value) {
            if ($null -ne $currentValue) {
                $msg = "Registry item $Path\$Name value was '$currentValue', set to '$Value'"
            }
            else {
                $msg = "Registry item $Path\$Name value was not existing, created with '$Value'"
            }

            if ($canWrite) {
                DoUpdate $msg {
                    $item.SetValue($Name, $Value, $Type)
                }
            } else {
                LogWarn "Registry item $Path\$Name cannot be updated"
            }
        }
        else {
            if ($canWrite) {
                DoUpdate "Registry item $Path\$Name removed, previous value was '$currentValue'" {
                    $item.DeleteValue($Name)
                }
            } else {
                LogWarn "Registry item $Path\$Name cannot be deleted"
            }
        }
    }
    else {
        if ($null -ne $Value) {
            LogIdempotent "Registry item $Path\$Name value is already set to '$Value'"
        }
        else {
            LogIdempotent "Registry item $Path\$Name is already missing"
        }
    }
}


Function IncrementGlobalAssociationChangedCounter {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "GlobalAssocChangedCounter" -Type DWORD -Value {
        Param($Value)
        return $Value + 1
    }
}

Function EnsureFirewallRule([String]$Name, [Boolean]$Activated) {
    Get-NetFirewallRule -Name $Name | ForEach-Object {
        $isEnabled = $_.Enabled -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Enabled]::True
        if ($Activated) {
            if ($isEnabled) {
                LogIdempotent "Firewall rule '$( $_.Name )' is already enabled"
            } else {
                if (IsAdmin) {
                    DoUpdate "Firewall rule '$( $_.Name )' was disabled, enabling it" {
                        Enable-NetFirewallRule -Name $_.Name
                    }
                } else {
                    LogWarn "Firewall rule '$( $_.Name )' cannot be enabled, it requires administrator privileges"
                }
            }
        } else {
            if ($isEnabled) {
                if (IsAdmin) {
                    DoUpdate "Firewall rule '$( $_.Name )' was enabled, disabling it" {
                        Disable-NetFirewallRule -Name $_.Name
                    }
                } else {
                    LogWarn "Firewall rule '$( $_.Name )' cannot be disabled, it requires administrator privileges"
                }
            } else {
                LogIdempotent "Firewall rule '$( $_.Name )' is already disabled"
            }
        }
    }
}

# See https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/configure-power-settings
Function EnsurePowerConfigValue($Setting, $Source, $Value) {
    $subGUID = KeyToValue $Setting @{
        ScreenTimeout = "7516b95f-f776-4464-8c53-06167f40cc99"
        SleepTimeOut = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
        PowerButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
        SleepButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
        LidButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
    }

    $settingGUID = KeyToValue $Setting @{
        ScreenTimeout = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
        SleepTimeOut = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
        PowerButtonAction = "7648efa3-dd9c-4e3e-b566-50f929386280"
        SleepButtonAction = "96996bc0-ad50-47ec-923b-6f41874dd9eb"
        LidButtonAction = "5ca83367-6e45-459f-a27b-476b1d01c936"
    }

    $itemName = KeyToValue $Source @{
        AC = "AcSettingIndex"
        DC = "DcSettingIndex"
    }

    $actionName = KeyToValue $Source @{
        AC = "/SETACVALUEINDEX"
        DC = "/SETDCVALUEINDEX"
    }

    $timeoutToIndex = {
        Param($val)
        if ($val -eq "Never") {
            return 0
        } else {
            return $val * 60
        }
    }

    $buttonActionToIndex = {
        Param($val)
        KeyToValue $val @{
            DoNothing = 0
            Sleep = 1
            Hibernate = 2
            Shutdown = 3
        }
    }

    $Value = ( KeyToValue $Setting @{
        ScreenTimeout = $timeoutToIndex
        SleepTimeOut = $timeoutToIndex
        PowerButtonAction = $buttonActionToIndex
        SleepButtonAction = $buttonActionToIndex
        LidButtonAction = $buttonActionToIndex
    }).InvokeReturnAsIs($Value)

    $currentSchemeGUID = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}" -Name "PreferredPlan"

    $currentValue = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$currentSchemeGUID\$subGUID\$settingGUID" -Name "$itemName" -ErrorAction SilentlyContinue
    if ($null -eq $currentValue) {
        $currentValue = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\$subGUID\$settingGUID\DefaultPowerSchemeValues\$currentSchemeGUID" -Name "$itemName" -ErrorAction SilentlyContinue
    }

    if ($Value -ne $currentValue) {
        DoUpdate "Power configuration $Setting on $Source value was '$currentValue', set to '$Value'" {
            powercfg.exe $actionName $currentSchemeGUID $subGUID $settingGUID $Value
        }
    } else {
        LogIdempotent "Power configuration $Setting on $Source value is already set to '$Value'"
    }
}

Function EnsureWindowsFeature($Features) {
    if (!(IsAdmin)) {
        LogWarn "Windows features management requires administrator privileges"
        return
    }

    foreach ($feature in Get-WindowsOptionalFeature -Online) {
        $featureName = $feature.FeatureName
        $featureEnabled = $feature.State -eq [Microsoft.Dism.Commands.FeatureState]::Enabled

        $desiredState = $Features[$featureName]
        if ($null -ne $desiredState) {
            $ensureEnabled = KeyToValue $desiredState @{
                Enabled = $true
                Disabled = $false
            }

            if ($ensureEnabled) {
                if ($featureEnabled) {
                    LogIdempotent "Windows feature '$featureName' is already enabled"
                } else {
                    DoUpdate "Windows feature '$featureName' has been enabled" {
                        Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart -WarningAction SilentlyContinue | Out-Null
                    }
                }
            } else {
                if ($featureEnabled) {
                    DoUpdate "Windows feature '$featureName' has been disabled" {
                        Disable-WindowsOptionalFeature -Online -FeatureName $featureName -NoRestart -WarningAction SilentlyContinue | Out-Null
                    }
                } else {
                    LogIdempotent "Windows feature '$featureName' is already disabled"
                }
            }
        }
    }
}

Function EnsureShortCut([String]$Shortcut, [String]$Target, [String]$Icon) {
    if (Test-Path -LiteralPath $Shortcut) {
        if ($Target) {
            LogIdempotent "Shortcut '$Shortcut' already exists"
        } else {
            DoUpdate "Shortcut '$Shortcut' deleted" {
                Remove-Item $Shortcut
            }
        }
    } else {
        if ($Target) {
            DoUpdate "Shortcut '$Shortcut' created" {
                $shortcutObj = (New-Object -comObject WScript.Shell).CreateShortcut($Shortcut)
                $shortcutObj.TargetPath = $Target
                if ($null -ne $Icon) {
                    $shortcutObj.IconLocation = $Icon
                }
                $shortcutObj.Save()
            }
        } else {
            LogIdempotent "Shortcut '$Shortcut' is already missing"
        }
    }
}

