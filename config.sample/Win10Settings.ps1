. "$(sboot_mod "Win10Tweaks")"

# Same as Settings -> System -> About -> Rename this PC
# See https://www.tenforums.com/tutorials/5174-change-computer-name-windows-10-a.html
Machine_ComputerName $env:ComputerName # $env:ComputerName | "<ComputerName>"

# Control execution of *.vbs scripts and similar
# See https://www.tenforums.com/performance-maintenance/92329-how-disable-windows-script-host.html
Machine_WindowsScriptHost Disabled  # Enabled | Disabled

# Control Flash in IE and Edge
# See https://www.tenforums.com/tutorials/8376-enable-disable-adobe-flash-player-microsoft-edge-windows-10-a.html
Machine_FlashInMSBrowsers Disabled  # Enabled | Disabled

# Same as Settings -> Update & Security -> Windows Security -> Virus & threat protection -> Virus & threat protection settings -> Manage settings -> Exclusion -> Add or remove exclusion
EnsureWindowsDefenderExclusion "D:\"

# Same as Control Panel -> System -> Advanced system settings -> Startup and Recovery -> Settings... -> System failure -> Automatically restart
# See https://www.tenforums.com/performance-maintenance/92329-how-disable-windows-script-host.html
Machine_AutoRebootOnCrash Disabled  # Enabled | Disabled

# Show more details when Windows starts or stop
# See https://www.thewindowsclub.com/enable-verbose-status-message-windows
Machine_VerboseStartupShutdownMessages Enabled  # Disabled | Enabled

# Control NTFS paths with length over 260 characters
Machine_NTFS_LongPaths Enabled  # Disabled | Enabled

# Control NTFS last access time
Machine_NTFS_LastAccess EnabledUserManaged  # DisabledUserManaged | EnabledUserManaged | DisabledSystemManaged | EnabledSystemManaged

# Control Cortana
# See https://www.tenforums.com/tutorials/25118-enable-disable-cortana-windows-10-a.html
Machine_Cortana Disabled  # Enabled | Disabled

# Control security questions for resetting local account password
# See https://www.tenforums.com/tutorials/117755-enable-disable-security-questions-local-accounts-windows-10-a.html
Machine_LocalAccountSecurityQuestions Disabled  # Enabled | Disabled

# Same as Settings -> Update & Security -> Windows Update -> Advanced options -> Delivery Optimization -> Allow downloads from other PCs
# See https://www.tenforums.com/tutorials/105329-specify-how-windows-store-app-updates-downloaded-windows-10-a.html
Machine_WindowsUpdateP2PDelivery Disabled  # LocalNetworkOnly | LocalNetworkAndInternet | Disabled

# Same as Control Panel -> Date and Time -> Internet Time -> Change settings... -> Server
# See https://www.tenforums.com/tutorials/6410-synchronize-clock-internet-time-server-windows-10-a.html
Machine_NtpServer "pool.ntp.org"  # "time.windows.com" | "pool.ntp.org"

# Enable strong crypto in .NET application
# See https://docs.microsoft.com/en-us/security-updates/SecurityAdvisories/2015/2960358
Machine_dotNETStrongCrypto Enabled  # Disabled | Enabled

# Control numlock on login screen
# See https://www.tenforums.com/tutorials/36010-enable-disable-num-lock-sign-screen-windows-10-a.html
Machine_SignInScreen_Numlock On  # Off | On

# Control access to Processor performance boost mode in Control Panel -> Power Options -> Change plan settings -> Change advanced power settings
EnsurePowerManagementSetting ProcessorPerformanceBoostMode Show

# Same as Settings -> System -> Power & sleep -> Screen -> On battery power, turn off after
EnsurePowerConfigValue -Setting ScreenTimeout -Source DC -Value 5 # 5
# Same as Settings -> System -> Power & sleep -> Screen -> When plugged in, turn off after
EnsurePowerConfigValue -Setting ScreenTimeout -Source AC -Value 20 # 10
# Same as Settings -> System -> Power & sleep -> Sleep -> On battery power, PC goes to sleep after
EnsurePowerConfigValue -Setting SleepTimeout -Source DC -Value 20 # 15
# Same as Settings -> System -> Power & sleep -> Sleep -> When plugged in, PC goes to sleep after
EnsurePowerConfigValue -Setting SleepTimeout -Source AC -Value 0 # 30
# Same as Control Panel -> Power Options -> Choose what closing the lid does -> When I close the lid / On battery
EnsurePowerConfigValue -Setting LidButtonAction -Source DC -Value DoNothing  # Sleep | Hibernate | Shutdown | DoNothing
# Same as Control Panel -> Power Options -> Choose what closing the lid does -> When I close the lid / Plugged in
EnsurePowerConfigValue -Setting LidButtonAction -Source AC -Value DoNothing  # Sleep | Hibernate | Shutdown | DoNothing

# Same as Settings -> Privacy -> Activity history
# See https://www.tenforums.com/tutorials/101852-enable-disable-timeline-windows-10-a.html
# See https://www.tenforums.com/tutorials/100341-enable-disable-collect-activity-history-windows-10-a.html
# See https://www.tenforums.com/tutorials/110063-enable-disable-sync-activities-pc-cloud-windows-10-a.html
Machine_ActivityHistory Disabled  # Enabled | Disabled

# Same as Settings -> System -> Clipboard -> Sync accross devices
# See https://www.tenforums.com/tutorials/110048-enable-disable-clipboard-sync-across-devices-windows-10-a.html
Machine_ClipboardSync Disabled  # Enabled | Disabled

# Same as Control Panel -> System -> Advanced system settings -> Remote -> Remote Assistance -> Allow Remote Assistance connections to this computer
# See https://www.tenforums.com/tutorials/116749-enable-disable-remote-assistance-connections-windows.html
Machine_RemoteAssistance Disabled  # Enabled | Disabled

# Same as Settings -> System -> Remote Desktop -> Enable Remote Desktop
# See https://www.tenforums.com/tutorials/116749-enable-disable-remote-assistance-connections-windows.html
Machine_RemoteDesktop Enabled  # Disabled | Enabled

# Remove Quick access from Explorer
# See https://www.tenforums.com/tutorials/4844-remove-quick-access-navigation-pane-windows-10-a.html
Machine_Explorer_QuickAccessInNavigationPane Show  # Show | Hide

# Remove duplicate removables drives in Explorer
# See https://www.tenforums.com/tutorials/4675-add-remove-duplicate-drives-navigation-pane-windows-10-a.html
Machine_Explorer_RemovableDrives_Duplicate Hide  # Show | Hide

# Control ZIP/CAB files as folders in Explorer
# See https://www.sevenforums.com/tutorials/13619-zip-folders-enable-disable-windows-explorer-view.html
Machine_Explorer_CompressedFolders Disabled  # Enabled | Disabled

# Control special folders viewing
# See https://www.tenforums.com/tutorials/6015-add-remove-folders-pc-windows-10-a.html
Machine_Explorer_SpecialFolder "3DObjects" Hide  # Show | Hide
Machine_Explorer_SpecialFolder Desktop Hide  # Show | Hide
Machine_Explorer_SpecialFolder Documents Show  # Show | Hide
Machine_Explorer_SpecialFolder Downloads Show  # Show | Hide
Machine_Explorer_SpecialFolder Music Hide  # Show | Hide
Machine_Explorer_SpecialFolder Pictures Show  # Show | Hide
Machine_Explorer_SpecialFolder Videos Hide  # Show | Hide

# Control Edge shortcut on desktop
# See https://www.tenforums.com/tutorials/7755-create-shortcut-microsoft-edge-windows-10-a.html
# See https://social.technet.microsoft.com/wiki/contents/articles/51546.windows-10-build-1803-registry-tweak-to-disable-microsoft-edge-shortcut-creation-on-desktop.aspx
Machine_EdgeDesktopLink Hide  # Show | Hide

# Control Fax printer
# Same as Settings -> Devices -> Printers & scanners -> Fax
Machine_FaxPrinter Uninstalled  # Installed | Uninstalled

# Control Xbox application and game mode
# Same as Settings -> Gaming -> Game Mode -> Game Mode
# Same as Settings -> Gaming -> Game Mode -> Game Mode
# See https://www.tenforums.com/tutorials/8637-turn-off-game-bar-windows-10-a.html
Machine_GamingFeatures Disabled  # Enabled | Disabled

# Control Apps
# Same as Settings -> Apps
EnsureWindowsApps @{
    "Microsoft.3DBuilder" = "Uninstalled"
    "Microsoft.AppConnector" = "Uninstalled"
    "Microsoft.BingFinance" = "Uninstalled"
    "Microsoft.BingFoodAndDrink" = "Uninstalled"
    "Microsoft.BingHealthAndFitness" = "Uninstalled"
    "Microsoft.BingMaps" = "Uninstalled"
    "Microsoft.BingNews" = "Uninstalled"
    "Microsoft.BingSports" = "Uninstalled"
    "Microsoft.BingTranslator" = "Uninstalled"
    "Microsoft.BingTravel" = "Uninstalled"
    "Microsoft.BingWeather" = "Uninstalled"
    "Microsoft.CommsPhone" = "Uninstalled"
    "Microsoft.ConnectivityStore" = "Uninstalled"
    "Microsoft.FreshPaint" = "Uninstalled"
    "Microsoft.GetHelp" = "Uninstalled"
    "Microsoft.Getstarted" = "Uninstalled"
    "Microsoft.HelpAndTips" = "Uninstalled"
    "Microsoft.Media.PlayReadyClient.2" = "Uninstalled"
    "Microsoft.Messaging" = "Uninstalled"
    "Microsoft.Microsoft3DViewer" = "Uninstalled"
    "Microsoft.MicrosoftOfficeHub" = "Uninstalled"
    "Microsoft.MicrosoftPowerBIForWindows" = "Uninstalled"
    "Microsoft.MicrosoftSolitaireCollection" = "Uninstalled"
    "Microsoft.MicrosoftStickyNotes" = "Uninstalled"
    "Microsoft.MinecraftUWP" = "Uninstalled"
    "Microsoft.MixedReality.Portal" = "Uninstalled"
    "Microsoft.MoCamera" = "Uninstalled"
    # "Microsoft.MSPaint" = "Uninstalled"
    "Microsoft.NetworkSpeedTest" = "Uninstalled"
    "Microsoft.OfficeLens" = "Uninstalled"
    "Microsoft.Office.OneNote" = "Uninstalled"
    "Microsoft.Office.Sway" = "Uninstalled"
    "Microsoft.OneConnect" = "Uninstalled"
    "Microsoft.People" = "Uninstalled"
    "Microsoft.Print3D" = "Uninstalled"
    "Microsoft.Reader" = "Uninstalled"
    "Microsoft.RemoteDesktop" = "Uninstalled"
    "Microsoft.SkypeApp" = "Uninstalled"
    "Microsoft.Todos" = "Uninstalled"
    "Microsoft.Wallet" = "Uninstalled"
    "Microsoft.WebMediaExtensions" = "Uninstalled"
    "Microsoft.Whiteboard" = "Uninstalled"
    "Microsoft.WindowsAlarms" = "Uninstalled"
    # "Microsoft.WindowsCamera" = "Uninstalled"
    "microsoft.windowscommunicationsapps" = "Uninstalled"
    "Microsoft.WindowsFeedbackHub" = "Uninstalled"
    "Microsoft.WindowsMaps" = "Uninstalled"
    "Microsoft.WindowsPhone" = "Uninstalled"
    # "Microsoft.Windows.Photos" = "Uninstalled"
    "Microsoft.WindowsReadingList" = "Uninstalled"
    "Microsoft.WindowsScan" = "Uninstalled"
    # "Microsoft.WindowsSoundRecorder" = "Uninstalled"
    "Microsoft.WinJS.1.0" = "Uninstalled"
    "Microsoft.WinJS.2.0" = "Uninstalled"
    "Microsoft.YourPhone" = "Uninstalled"
    "Microsoft.ZuneMusic" = "Uninstalled"
    "Microsoft.ZuneVideo" = "Uninstalled"
    "Microsoft.Advertising.Xaml" = "Uninstalled"
}


# Control Windows Features
# Same as Control Panel -> Programs and Features -> Turn Windows features on or off
EnsureWindowsFeature @{
    "TelnetClient" = "Enabled"
    "Microsoft-Hyper-V-All" = "Enabled"
    "Containers" = "Enabled"
    "Containers-DisposableClientVM" = "Enabled"
    "Microsoft-Windows-Subsystem-Linux" = "Enabled"

    "WindowsMediaPlayer" = "Disabled"
    "Printing-XPSServices-Features" = "Disabled"
    "SMB1Protocol" = "Disabled"
    "MicrosoftWindowsPowerShellV2Root" = "Disabled"
    "WorkFolders-Client" = "Disabled"
    "FaxServicesClientPackage" = "Disabled"
}

# Same as Taskbar context menu -> Show task view button
# See https://www.tenforums.com/tutorials/2853-hide-show-task-view-button-taskbar-windows-10-a.html
User_Taskbar_TaskViewButton Hide  # Show | Hide
# Same as Taskbar context menu -> Search
# See https://www.tenforums.com/tutorials/2854-hide-show-search-box-search-icon-taskbar-windows-10-a.html
User_Taskbar_SearchArea Hide  # ShowBox | ShowIcon | Hide
# Same as Taskbar context menu -> Show People on the taskbar
# See https://www.tenforums.com/tutorials/83096-add-remove-people-button-taskbar-windows-10-a.html
User_Taskbar_PeopleBand Hide  # Hide | Show
# Same as Settings -> Personalization -> Taskbar -> Select which icons appear on taskbar -> Always show all icons in the notification area
# See https://www.tenforums.com/tutorials/5313-hide-show-notification-area-icons-taskbar-windows-10-a.html
User_Taskbar_NotificationIcons ShowAll  # ShowFrequentlyUsed | ShowAll
# Show seconds in the taskbar clock
# See https://www.tenforums.com/tutorials/73967-hide-show-seconds-taskbar-clock-windows-10-a.html
User_Taskbar_Clock_Seconds Show  # Hide | Show
# Same as Settings -> Personalization -> Taskbar -> Multiple displays -> Multiple displays
# See https://www.tenforums.com/tutorials/3899-hide-show-taskbar-multiple-displays-windows-10-a.html
User_Taskbar_MultipleMonitors ShowButtonWhereOpenTaskbar  # Disabled | ShowButtonOnAllTaskbar | ShowButtonOnMainTaskbarAndWhereOpenTaskbar | ShowButtonWhereOpenTaskbar

# Same as Settings -> Personalization -> Themes -> Desktop icon settings
# See https://www.tenforums.com/tutorials/6942-add-remove-default-desktop-icons-windows-10-a.html
User_Desktop_Icon Computer Show  # Hide | Show
User_Desktop_Icon UsersFiles Show  # Hide | Show
User_Desktop_Icon Network Show  # Hide | Show
User_Desktop_Icon RecycleBin Show  # Show | Hide
User_Desktop_Icon ControlPanel Show  # Hide | Show

# Same as File Explorer Options -> General -> Open File Explorer to
# See https://www.tenforums.com/tutorials/3734-open-pc-quick-access-file-explorer-windows-10-a.html
User_Explorer_OpenTo ThisPC  # QuickAccess | ThisPC
# Same as File Explorer Options -> General -> Privacy -> Show recently used files in Quick access
# See https://www.tenforums.com/tutorials/2713-add-remove-recent-files-quick-access-windows-10-a.html
User_Explorer_RecentlyUsedFileInQuickAccess Hide  # Show | Hide
# Same as File Explorer Options -> General -> Privacy -> Show frequently used folders in Quick access
# See https://www.tenforums.com/tutorials/2712-add-remove-frequent-folders-quick-access-windows-10-a.html
User_Explorer_FrequentlyUsedFoldersInQuickAccess Hide  # Show | Hide
# Same as File Explorer Options -> View -> Display the full path in the title bar
# See https://www.tenforums.com/tutorials/3430-display-full-path-title-bar-file-explorer-windows-10-a.html
User_Explorer_TitleBarDisplay FullPath  # LastPathElementOnly | FullPath
# Same as File Explorer Options -> View -> Hide extensions for known file types
# See https://www.tenforums.com/tutorials/62842-hide-show-file-name-extensions-windows-10-a.html
User_Explorer_FileExtension AlwaysShow  # HideForKnownTypes | AlwaysShow
# Same as File Explorer Options -> View -> Hidden files and folders
# See https://www.tenforums.com/tutorials/9168-show-hidden-files-folders-drives-windows-10-a.html
User_Explorer_HiddenFiles Show  # Hide | Show
# Same as File Explorer Options -> View -> Show drive letters (with more options)
# See https://www.tenforums.com/tutorials/64249-show-drive-letters-before-after-name-windows-10-a.html
User_Explorer_DriveLabel LetterThenLabel  # LabelThenLetter | OnlyNetworkDriveLetterThenLabel | LabelOnly | LetterThenLabel
# Same as File Explorer Options -> View -> Show encrypted or compressed NTFS files in color
# See https://www.tenforums.com/tutorials/89204-show-encrypted-compressed-ntfs-files-color-windows-10-a.html
User_Explorer_ShowCompressedOrEncryptedFilesInColor Enabled  # Disabled | Enabled
# Same as File Explorer Options -> View -> Show sync provider notifications
# See https://www.tenforums.com/tutorials/59897-hide-show-file-explorer-sync-provider-notifications-windows-10-a.html
User_Explorer_SyncProviderNotifications Hide  # Show | Hide
# Same as File Explorer Options -> View -> Navigation pane -> Expand to open folder
# See https://www.tenforums.com/tutorials/65186-turn-off-navigation-pane-expand-open-folder-windows-10-a.html
User_Explorer_NavigationPaneExpandToOpenFolder Enabled  # Disabled | Enabled
# Control explorer search box history
# See https://www.tenforums.com/tutorials/88749-enable-disable-search-history-windows-10-file-explorer.html
User_Explorer_SearchBoxHistory Disabled  # Enabled | Disabled
# Control OneDrive default folder display
# See https://www.tenforums.com/tutorials/4818-add-remove-onedrive-navigation-pane-windows-10-a.html
User_Explorer_OneDriveDefaultFolder Hide  # Show | Hide
# Control the details level of Explorer file transfer dialog
# See https://www.tenforums.com/tutorials/60654-show-fewer-more-details-file-transfer-dialog-windows-10-a.html
User_Explorer_FileTransferDetails Show  # Hide | Show

# Same as Control Panel -> View by
# See https://www.thewindowsclub.com/control-panel-category-list-view-windows
User_ControlPanelLayout SmallIcons  # Category | LargeIcons | SmallIcons

# Same as Settings -> Accounts -> Sign-in options -> Use my sign-in info to automatically finish setting up my device and reopen my apps after an update
# See https://www.tenforums.com/tutorials/49963-use-sign-info-auto-finish-after-update-restart-windows-10-a.html
User_ApplicationAutoRestart Disabled  # Enabled | Disabled

# Same as Settings -> Devices -> AutoPlay -> Use AutoPlay for all media and drives
# See https://www.tenforums.com/tutorials/7119-turn-off-autoplay-windows-10-a.html
# See https://www.tenforums.com/tutorials/101962-enable-disable-autoplay-all-drives-windows.html
User_AutoPlay Disabled  # Enabled | Disabled

# Same as Settings -> Privacy -> Diagnostics & feedback -> Tailored experiences
# See https://www.tenforums.com/tutorials/76426-turn-off-tailored-experiences-diagnostic-data-windows-10-a.html
User_TailoredExperiences Disabled  # Enabled | Disabled

# Same as Settings -> Privacy -> Diagnostics & feedback -> Feedback frequency
# See https://www.tenforums.com/tutorials/2441-change-feedback-frequency-windows-10-a.html
User_FeedbackFrequency Never  # Automatically | Always | OnceADay | OnceAWeek | Never

# Same as Settings -> System -> Clipboard -> Clipboard history
# See https://www.tenforums.com/tutorials/110048-enable-disable-clipboard-sync-across-devices-windows-10-a.html
User_ClipboardHistory Disabled  # Disabled | Enabled

# Same as Settings -> System -> Shared experiences
# See https://www.tenforums.com/tutorials/70947-turn-off-share-across-devices-apps-window-10-a.html
# See https://www.tenforums.com/tutorials/97582-turn-off-nearby-sharing-windows-10-a.html
User_SharedExperiences Disabled  # Enabled | NearByOnly | DevicesOnly | Disabled

# Same as Settings -> Privacy -> Diagnostics & feedback -> General -> Let apps use advertising ID...
# See https://www.tenforums.com/tutorials/76453-enable-disable-advertising-id-relevant-ads-windows-10-a.html
User_AdvertisingID Disabled  # Enabled | Disabled

# Same as Settings -> Personalization -> Start -> Show recently opened items in Jump Lists on Start or the taskbar and in File Explorer Quick Access
# See https://www.tenforums.com/tutorials/3469-turn-off-recent-items-frequent-places-windows-10-a.html
User_TrackDocumentHistory Disabled  # Enabled | Disabled

# Same as Settings -> Privacy -> General -> Let Windows track app launches to improve Start and search results
# See https://www.tenforums.com/tutorials/3469-turn-off-recent-items-frequent-places-windows-10-a.html
User_TrackApplicationHistory Disabled  # Enabled | Disabled


# Save download zone information in file ADS
# See https://www.tenforums.com/tutorials/85418-disable-downloaded-files-being-blocked-windows.html
User_Downloads_SaveZoneInformation Disabled  # Enabled | Disabled

# Same as Settings -> Ease of Access -> Keyboard
# See https://www.tenforums.com/tutorials/115391-turn-off-sticky-keys-windows-10-a.html
User_StickyKeys Disabled  # Enabled | Disabled

# Tune touchpad gesture
User_TouchPad Simple  # Default | Simple

# Same as Settings -> Devices -> Typing -> Advanced keyboard settings -> Input language hot keys -> Hot keys for input languages
# See https://winaero.com/blog/change-hotkeys-switch-keyboard-layout-windows-10
User_LanguageHotKeys Disabled  # Enabled | Disabled

# Same as OneDrive -> Settings -> Settings -> Start OneDrive automatically when I sign in to Windows
User_OneDrive_AutoStart Disabled  # Enabled | Disabled

# Same as Intel Graphics Settings -> Preferences
User_IntelGFXTray Hide  # Show | Hide

# Same as Intel Graphics Settings -> Hot Key Manager -> Manage Hot Keys
User_IntelGFXHotKeys Disabled  # Enabled | Disabled