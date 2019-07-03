$scoopTarget = 'D:\scoop'
$changeExecutionPolicy = (Get-ExecutionPolicy) -gt 'RemoteSigned' -or (Get-ExecutionPolicy) -eq 'ByPass'

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host -ForegroundColor Yellow "Aborting installation. Script need to be executed as administrator."
    return
}

$scoopPersistUrl = Read-Host "Enter your Scoop persist directory's Git repository URL: "

Write-Host "Scoop will be installed to $scoopTarget"
if ($changeExecutionPolicy) {
    Write-Host "Current user execution policy will be set to RemoteSigned"
} else {
    Write-Host "Current user execution policy don't need to be changed (current value is $( Get-ExecutionPolicy ))"
}
Write-Host ""

Write-Host "Do you want to proceed with the sboot installation ?"

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
if ($decision -ne 0) {
    Write-Host 'Cancelled'
    return
}

$env:SCOOP = $scoopTarget
[environment]::setEnvironmentVariable('SCOOP', $scoopTarget, 'User')
if ($changeExecutionPolicy) {
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force
}
Invoke-WebRequest -useb 'https://get.scoop.sh' | Invoke-Expression

scoop install git
scoop update
scoop update *

Remove-Item "$scoopTarget\persist" -Force
git clone "$scoopPersistUrl" "$scoopTarget\persist"

scoop bucket add sboot https://github.com/xfournet/scoop-sboot.git
scoop install sboot/sboot

## Install profile loader
if (!(Test-Path $PROFILE)) {
    $profileDir = Split-Path $PROFILE
    if (!(Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory | Out-Null
    }

    '' > $PROFILE
}

$text = Get-Content $PROFILE

if ($null -eq ($text | Select-String '#sboot-profiles')) {
    # read and write whole profile to avoid problems with line endings and encodings
    $new_profile = @($text) + "#sboot-profiles" + '. "$env:SCOOP\apps\sboot\current\bin\load-profiles.ps1"'
    $new_profile > $PROFILE
}

Write-Host ""
Write-Host "Scoop bootstrapped. If everything is OK, execute 'sboot apply -All' command. If you are unsure, first execute 'sboot apply -All -WhatIf'"
