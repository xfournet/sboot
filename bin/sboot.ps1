$sboot_verbose = $false
$sboot_dryRun = $false
$sboot_all = $false
$sboot_command = $null
$sboot_command_args = new-object collections.generic.list[object]

[ref]$sboot_update_count = 0

if ($args) {
    foreach ($arg in $args) {
        if ($arg.ToLower() -eq "-verbose") {
            $sboot_verbose = $true
        } elseif ($arg.ToLower() -eq "-whatif") {
            $sboot_dryRun = $true
        } elseif ($arg.ToLower() -eq "-all") {
            $sboot_all = $true
        } elseif($null -eq $sboot_command) {
            $sboot_command = $arg
        } else {
            $sboot_command_args.Add($arg)
        }
    }
}

Function IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
}

Function IsVerbose {
    return $sboot_verbose
}

Function IsDryRun {
    return $sboot_dryRun
}

Function DoUpdate([switch] $RequireAdmin, $Message, $UpdateScript) {
    $sboot_update_count.Value = $sboot_update_count.Value + 1
    if (IsDryRun) {
        LogUpdate "What if: $Message"
    } else {
        if($RequireAdmin -And (IsAdmin) -Or !($RequireAdmin)) {
            LogUpdate $Message
            $UpdateScript.InvokeReturnAsIs()
        } else {
            LogWarn "Update requires administrator privileges: $Message"
        }
    }
}


Function GetUpdateCount {
    return $sboot_update_count.Value
}

Function LogUpdate($Message) {
    #    Write-Output "[UPDATE] $Message"
    Write-Host -ForegroundColor Cyan $Message
}

Function LogIdempotent($Message) {
    #    Write-Output "[IDEM ] $Message"
    if (IsVerbose) {
        Write-Host -ForegroundColor Green $Message
    }
}

Function LogWarn($Message) {
    #    Write-Output "[WARN ] $Message"
    Write-Host -ForegroundColor Yellow $Message
}

Function LogMessage($Message) {
    #    Write-Output "[MSG   ] $Message"
    Write-Host $Message
}

Function sboot_mod([String]$moduleSpec) {
    if ($moduleSpec -match "^(([^/]+)/)?(.+)$") {
        $appName = $Matches[1]
        $modName = $Matches[3]

        if ($null -eq $appName) {
            $appName = "sboot"
        }

        return "$( scoop prefix $appName )/sboot_mods/$modName.ps1"
    } else {
        throw "Invalid module spec : $moduleSpec"
    }
}

Function sboot_cfg([String]$Name, [switch]$Default) {
    if ($( if ($sboot_command_args.Length) {
        $sboot_command_args.contains($Name)
    } else {
        $Default -or $sboot_all
    } )) {
        LogMessage "Applying config '$Name'"
        Invoke-Expression "$PSScriptRoot\..\config\$Name.ps1"
    } elseif(IsVerbose) {
        LogMessage "Skipping config '$Name'"
    }
}

Function DoApply {
    Invoke-Expression "$PSScriptRoot\..\config\config.ps1"
}


if ($sboot_command -eq "apply") {
    DoApply
} else {
    "Usage: sboot <command> [<args>]"
    ""
    "Commands are:"
    ""
    "apply       Apply configurations"
}