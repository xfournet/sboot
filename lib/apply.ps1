param($apps, $verbose, $dryRun)

Function ShouldProcessApp([String]$AppName, [switch]$Default) {
    if ($apps.Length -gt 0) {
        return $apps.contains($AppName) -or $apps.contains('*')
    } else {
        return $Default
    }
}

Function IsVerbose {
    return $verbose
}

Function IsDryRun {
    return $dryRun
}

Function IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
}

Function DoUpdate([switch] $RequireAdmin, [String]$Message, [ScriptBlock]$UpdateScript) {
    if (IsDryRun) {
        LogUpdate "What if: $Message"
    } else {
        if ($RequireAdmin -And (IsAdmin) -Or !($RequireAdmin)) {
            LogUpdate $Message
            & $UpdateScript
        } else {
            LogWarn "Update requires administrator privileges: $Message"
        }
    }
}

Function LogUpdate([String]$Message) {
    #    Write-Output "[UPDATE] $Message"
    Write-Host -ForegroundColor Cyan $Message
}

Function LogIdempotent([String]$Message) {
    #    Write-Output "[IDEM ] $Message"
    if (IsVerbose) {
        Write-Host -ForegroundColor Green $Message
    }
}

Function LogWarn([String]$Message) {
    #    Write-Output "[WARN ] $Message"
    Write-Host -ForegroundColor Yellow $Message
}

Function LogMessage([String]$Message) {
    #    Write-Output "[MSG   ] $Message"
    Write-Host $Message
}

Function sboot_mod([String]$moduleSpec) {
    if ($moduleSpec -match "^(([^/]+)/)?(.+)$") {
        $appName = $Matches[1]
        $modName = $Matches[3]

        if (!$appName) {
            $appName = "sboot"
        }

        return "$( scoop prefix $appName )/sboot_mods/$modName.ps1"
    } else {
        throw "Invalid module spec : $moduleSpec"
    }
}

Function sboot_cfg([String]$Name, [switch]$Default, [ScriptBlock]$Script) {
    if (ShouldProcessApp -AppName $Name -Default:$Default) {
        LogMessage "Applying config '$Name'"
        if ($Script) {
            & $Script
        } else {
            & "$PSScriptRoot\..\config\$Name.ps1"
        }
    } elseif(IsVerbose) {
        LogMessage "Skipping config '$Name'"
    }
}
