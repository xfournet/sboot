. "$( sboot_mod "Utils" )"

Function Machine_ComputerName([String]$ComputerName) {
    if ($ComputerName -ne $env:ComputerName) {
        DoUpdate "Computer renamed to '$ComputerName', previous name was '$env:ComputerName'" {
            Rename-Computer -NewName $ComputerName
        }
    } else {
        LogIdempotent "Computer name is already set to '$ComputerName'"
    }
}

Function Machine_WindowsScriptHost($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function Machine_FlashInMSBrowsers($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function Machine_WindowsUpdateAutoWakeUp($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function Machine_AutoRebootOnCrash($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 1
        Disabled = 0
    })
}

Function Machine_VerboseStartupShutdownMessages($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        Enabled = 1
    })
}

Function Machine_NTFS_LongPaths($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = 0
        Enabled = 1
    })
}

Function Machine_NTFS_LastAccess($Action) {
    $output = (fsutil.exe behavior query DisableLastAccess) | Out-String
    $output -match ".* = ([0-9]) .*" | Out-Null
    $currentValue = $Matches[1]
    $value = KeyToValue $Action @{
        DisabledUserManaged = 0
        EnabledUserManaged = 1
        DisabledSystemManaged = 2
        EnabledSystemManaged = 3
    }
    if ($currentValue -ne $value) {
        DoUpdate "NTFS DisableLastAccess value was '$currentValue', set to '$value'" {
            (fsutil.exe behavior set DisableLastAccess $value) | Out-Null
        }
    } else {
        LogIdempotent "NTFS DisableLastAccess is already set to '$currentValue'"
    }
}

Function Machine_Cortana($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function Machine_LocalAccountSecurityQuestions($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" -Name "NoLocalPasswordResetQuestions" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
}

Function Machine_WindowsUpdateP2PDelivery($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWORD -Value ( KeyToValue $Action @{
        LocalNetworkOnly = $null
        LocalNetworkAndInternet = 3
        Disabled = 100
    })
}

Function Machine_NtpServer($NtpServer) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "NtpServer" -Type String -Value "$NtpServer,0x9"
}

Function Machine_dotNETStrongCrypto($Action) {
    $value = KeyToValue $Action @{
        Disabled = $null
        Enabled = 1
    }
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" -Name "SchUseStrongCrypto" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727" -Name "SchUseStrongCrypto" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWORD -Value $value
}

Function Machine_SignInScreen_Numlock($Action) {
    EnsureRegistryValue -Path "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type String -Value ( KeyToValue $Action @{
        Off = {
            Param($Value)

            Add-Type -AssemblyName System.Windows.Forms
            if ( [System.Windows.Forms.Control]::IsKeyLocked('NumLock')) {
                $wsh = New-Object -ComObject WScript.Shell
                $wsh.SendKeys('{NUMLOCK}')
            }

            return $Value -band (-bnot2)
        }
        On = {
            Param($Value)

            Add-Type -AssemblyName System.Windows.Forms
            if (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
                $wsh = New-Object -ComObject WScript.Shell
                $wsh.SendKeys('{NUMLOCK}')
            }

            return $Value -bor 2
        }
    })
}

Function Machine_ActivityHistory($Action) {
    $value = KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    }
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWORD -Value $value
}

Function Machine_ClipboardSync($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowCrossDeviceClipboard" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function Machine_RemoteAssistance($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
    EnsureFirewallRule "RemoteAssistance-*" -Activated ( KeyToValue $Action @{
        Enabled = $true
        Disabled = $false
    })
    EnsureWindowsCapability @{
        "App.Support.QuickAssist" = ( KeyToValue $Action @{
            Enabled = "Installed"
            Disabled = "NotPresent"
        })
    }
}

Function Machine_RemoteDesktop($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = 1
        Enabled = 0
    })
    EnsureFirewallRule -Name "RemoteDesktop-*" -Activated ( KeyToValue $Action @{
        Disabled = $false
        Enabled = $true
    })
}

Function Machine_Explorer_QuickAccessInNavigationPane($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "HubMode" -Type DWORD -Value ( KeyToValue $Action @{
        Show = $null
        Hide = 1
    })
}

Function Machine_Explorer_RemovableDrives_Duplicate($Action) {
    & (KeyToValue $Action @{
        Show = {
            EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" -Name "@" -Type String -Value "Removable Drives"
            EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" -Name "@" -Type String -Value "Removable Drives"
        }
        Hide = {
            EnsureRegistryKeyDeleted -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
            EnsureRegistryKeyDeleted -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
        }
    })
}

Function Machine_Explorer_CompressedFolders($Action) {
    $zipCLSID = KeyToValue $Action @{
        Enabled = "{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}"
        Disabled = $null
    }
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CompressedFolder\CLSID" -Name "" -Type String -Value $zipCLSID
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\SystemFileAssociations\.zip\CLSID" -Name "" -Type String -Value $zipCLSID

    $cabCLSID = KeyToValue $Action @{
        Enabled = "{0CD7A5C0-9F37-11CE-AE65-08002B2E1262}"
        Disabled = $null
    }
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CABFolder\CLSID" -Name "" -Type String -Value $cabCLSID
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\SystemFileAssociations\.cab\CLSID" -Name "" -Type String -Value $cabCLSID
}

Function Machine_Explorer_SpecialFolder($Folder, $Action) {
    $uuid = KeyToValue $Folder @{
        "3DObjects" = "31C0DD25-9439-4F12-BF41-7FF4EDA38722"
        Desktop = "B4BFCC3A-DB2C-424C-B029-7FE99A87C641"
        Documents = "f42ee2d3-909f-4907-8871-4c22fc0bf756"
        Downloads = "7d83ee9b-2244-4e70-b1f5-5393042af1e4"
        Music = "a0c69a99-21c8-4671-8703-7934162fcf1d"
        Pictures = "0ddd015d-b06c-45d5-8c4c-f59713854639"
        Videos = "35286a68-3c57-41a1-bbb1-0eae73d76c95"
    }

    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{$uuid}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value ( KeyToValue $Action @{
        Show = "Show"
        Hide = "Hide"
    })
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{$uuid}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value ( KeyToValue $Action @{
        Show = "Show"
        Hide = "Hide"
    })
}

Function Machine_EdgeDesktopLink($Action) {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWORD -Value ( KeyToValue $Action @{
        Show = $null
        Hide = 1
    })

    $edgeLink = "$env:USERPROFILE\Desktop\Microsoft Edge.lnk"
    if ($Action -eq "Show") {
        EnsureShortCut -Shortcut $edgeLink -Target "shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" -Icon "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe"
    } else {
        EnsureShortCut -Shortcut $edgeLink -Target $null
    }
}

Function Machine_FaxPrinter($Action) {
    $installed = ($null -ne (Get-Printer -Name "Fax" -ErrorAction SilentlyContinue))
    & (KeyToValue $Action @{
        Installed = {
            if ($installed) {
                LogIdempotent "Fax printer is already installed"
            } else {
                DoUpdate -RequireAdmin "Fax printer has been installed" {
                    Add-Printer -Name "Fax" -DriverName "Microsoft Shared Fax Driver" -PortName "SHRFAX:"
                }
            }
        }
        Uninstalled = {
            if ($installed) {
                DoUpdate -RequireAdmin "Fax printer has been uninstalled" {
                    Remove-Printer -Name "Fax"
                }
            } else {
                LogIdempotent "Fax printer is already uninstalled"
            }
        }
    })
}

Function Machine_GamingFeatures($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 1
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 0
        Disabled = 1
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 2
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 0
        Disabled = 2
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 0
        Disabled = 1
    })

    $installState = KeyToValue $Action @{
        Enabled = "Installed"
        Disabled = "Uninstalled"
    }

    EnsureWindowsApps @{
        "Microsoft.XboxApp" = $installState
        "Microsoft.XboxIdentityProvider" = $installState
        "Microsoft.XboxSpeechToTextOverlay" = $installState
        "Microsoft.XboxGameOverlay" = $installState
        "Microsoft.XboxGamingOverlay" = $installState
        "Microsoft.Xbox.TCUI" = $installState
    }
}

Function User_StartMenu_Tiles($Action) {
    & (KeyToValue $Action @{
        Unpin = {
            $keyPath = (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current").PSPath
            $keyPath = $keyPath.Substring($keyPath.IndexOf("::") + 2)
            EnsureRegistryValue -Path $keyPath -Name "Data" -Type Binary {
                Param($Data)
                return ($Data[0..25] + ([byte[]](202, 50, 0, 226, 44, 1, 1, 0, 0)))
            }
            Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
        }
        Keep = { }
    })
}

Function User_Taskbar_TaskViewButton($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWORD -Value ( KeyToValue $Action @{
        Show = $null
        Hide = 0
    })
}

Function User_Taskbar_SearchArea($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWORD -Value ( KeyToValue $Action @{
        ShowBox = $null
        ShowIcon = 1
        Hide = 0
    })
}

Function User_Taskbar_PeopleBand($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWORD -Value ( KeyToValue $Action @{
        Hide = $null
        Show = 1
    })
}

Function User_Taskbar_NotificationIcons($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWORD -Value ( KeyToValue $Action @{
        ShowFrequentlyUsed = 1
        ShowAll = 0
    })
}

Function User_Taskbar_Clock_Seconds($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Type DWORD -Value ( KeyToValue $Action @{
        Hide = $null
        Show = 1
    })
}

Function User_Taskbar_MultipleMonitors($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        ShowButtonOnAllTaskbar = 1
        ShowButtonOnMainTaskbarAndWhereOpenTaskbar = 1
        ShowButtonWhereOpenTaskbar = 1
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarMode" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        ShowButtonOnAllTaskbar = 0
        ShowButtonOnMainTaskbarAndWhereOpenTaskbar = 1
        ShowButtonWhereOpenTaskbar = 2
    })
}

Function User_Desktop_Icon($Icon, $Action) {
    $uuid = KeyToValue $Icon @{
        Computer = "20D04FE0-3AEA-1069-A2D8-08002B30309D"
        UsersFiles = "59031a47-3f72-44a7-89c5-5595fe6b30ee"
        Network = "F02C1A0D-BE21-4350-88B0-7367FC96EF3C"
        RecycleBin = "645FF040-5081-101B-9F08-00AA002F954E"
        ControlPanel = "5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0"
    }
    $value = KeyToValue $Action $( if ($Icon -eq "RecycleBin") {
        @{
            Show = $null
            Hide = 1
        }
    } else {
        @{
            Hide = $null
            Show = 0
        }
    } )
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{$uuid}" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{$uuid}" -Type DWORD -Value $value
}

Function User_Explorer_OpenTo($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWORD -Value ( KeyToValue $Action @{
        QuickAccess = $null
        ThisPC = 1
    })
}

Function User_Explorer_RecentlyUsedFileInQuickAccess($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWORD -Value ( KeyToValue $Action @{
        Show = $null
        Hide = 0
    })
}

Function User_Explorer_FrequentlyUsedFoldersInQuickAccess($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWORD -Value ( KeyToValue $Action @{
        Show = $null
        Hide = 0
    })
}

Function User_Explorer_TitleBarDisplay($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWORD -Value ( KeyToValue $Action @{
        LastPathElementOnly = $null
        FullPath = 1
    })
}

Function User_Explorer_FileExtension($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWORD -Value ( KeyToValue $Action @{
        HideForKnownTypes = 1
        AlwaysShow = 0
    })
}

Function User_Explorer_HiddenFiles($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWORD -Value ( KeyToValue $Action @{
        Hide = 2
        Show = 1
    })
}

Function User_Explorer_DriveLabel($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowDriveLettersFirst" -Type DWORD -Value ( KeyToValue $Action @{
        LabelThenLetter = $null
        OnlyNetworkDriveLetterThenLabel = 1
        LabelOnly = 2
        LetterThenLabel = 4
    })
}

Function User_Explorer_ShowCompressedOrEncryptedFilesInColor($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptCompressedColor" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        Enabled = 1
    })
}

Function User_Explorer_SyncProviderNotifications($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWORD -Value ( KeyToValue $Action @{
        Show = 1
        Hide = 0
    })
}

Function User_Explorer_NavigationPaneExpandToOpenFolder($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        Enabled = 1
    })
}

Function User_Explorer_SearchBoxHistory($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
}

Function User_Explorer_OneDriveDefaultFolder($Action) {
    $Path = "HKEY_CURRENT_USER\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    if (Test-Path -LiteralPath "Registry::$Path") {
        EnsureRegistryValue -Path $Path -Name "System.IsPinnedToNameSpaceTree" -Type DWORD -Value ( KeyToValue $Action @{
            Show = 1
            Hide = 0
        })
    }
}

Function User_Explorer_FileTransferDetails($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWORD -Value ( KeyToValue $Action @{
        Hide = $null
        Show = 1
    })
}

Function User_ControlPanelLayout($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWORD -Value ( KeyToValue $Action @{
        Category = $null
        LargeIcons = 0
        SmallIcons = 1
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWORD -Value ( KeyToValue $Action @{
        Category = $null
        LargeIcons = 1
        SmallIcons = 1
    })
}

Function User_ApplicationAutoRestart($Action) {
    $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$sid" -Name "OptOut" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
}

Function User_AutoPlay($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 255
    })
}

Function User_TailoredExperiences($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = 0
        Enabled = 1
    })
}

Function User_FeedbackFrequency($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Type DWORD -Value ( KeyToValue $Action @{
        Automatically = $null
        Always = 100000000
        OnceADay = 864000000000
        OnceAWeek = 6048000000000
        Never = $null
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWORD -Value ( KeyToValue $Action @{
        Automatically = $null
        Always = $null
        OnceADay = 1
        OnceAWeek = 1
        Never = 0
    })
}

Function User_ClipboardHistory($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWORD -Value ( KeyToValue $Action @{
        Disabled = $null
        Enabled = 1
    })
}

Function User_SharedExperiences($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "CdpSessionUserAuthzPolicy" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 2
        NearByOnly = 2
        DevicesOnly = 1
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "NearShareChannelUserAuthzPolicy" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 2
        NearByOnly = 2
        DevicesOnly = 0
        Disabled = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 1
        NearByOnly = 0
        DevicesOnly = 1
        Disabled = 0
    })
}

Function User_AdvertisingID($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 1
        Disabled = 0
    })
}

Function User_TrackDocumentHistory($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function User_TrackApplicationHistory($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 0
    })
}

Function User_Downloads_SaveZoneInformation($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -Name "SaveZoneInformation" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 1
    })
}

Function User_StickyKeys($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 510
        Disabled = 506
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 62
        Disabled = 58
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = 126
        Disabled = 122
    })
}

Function User_TouchPad($Profile) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "TapAndDrag" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = 1
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "TapsEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = 1
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "TwoFingerTapEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = 1
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "ZoomEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = 1
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "ThreeFingerSlideEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = $null
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "ThreeFingerTapEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = $null
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "FourFingerSlideEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = $null
        Simple = 0
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "FourFingerTapEnabled" -Type DWORD -Value ( KeyToValue $Profile @{
        Default = $null
        Simple = 0
    })
}

Function User_LanguageHotKeys($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Keyboard Layout\Toggle" -Name "Hotkey" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 3
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Keyboard Layout\Toggle" -Name "Language Hotkey" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 3
    })
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Keyboard Layout\Toggle" -Name "Layout Hotkey" -Type DWORD -Value ( KeyToValue $Action @{
        Enabled = $null
        Disabled = 3
    })
}

Function User_OneDrive_AutoStart($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Type String -Value ( KeyToValue $Action @{
        Enabled = """$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"" /background"
        Disabled = $null
    })
}

Function User_IntelGFXTray($Action) {
    $value = KeyToValue $Action @{
        Show = 1
        Hide = 0
    }

    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray\TrayIcon" -Name "ShowTrayIcon" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowBalloon" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowDPTBalloon" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowGaming" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowGamingNotification" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowGraphicsBalloon" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowOptimalBalloon" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowPromotions" -Type DWORD -Value $value
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\igfxtray" -Name "ShowPromotionsNotification" -Type DWORD -Value $value
}

Function User_IntelGFXHotKeys($Action) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\HotKeys" -Name "Enable" -Type DWORD -Value (KeyToValue $Action @{
        Enabled = 1
        Disabled = 0
    })
}
