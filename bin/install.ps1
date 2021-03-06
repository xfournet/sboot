$changeExecutionPolicy = (Get-ExecutionPolicy) -gt 'RemoteSigned' -or (Get-ExecutionPolicy) -eq 'ByPass'

$scoopTarget = Read-Host "Enter your Scoop installation directory (e.g. D:\scoop)"
$scoopPersistUrl = Read-Host "Enter your Scoop persist directory's Git repository URL (e.g. https://github.com/xfournet/scoop-persist.git)"
$scoopPersistBranch = Read-Host "Enter your Scoop persist directory's Git repository branch name (e.g. master)"

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

if (Test-Path -LiteralPath "$scoopTarget\persist") {
    Remove-Item "$scoopTarget\persist" -Force
}
git clone -n "$scoopPersistUrl" "$scoopTarget\persist"
pushd "$scoopTarget\persist"
git checkout "$scoopPersistBranch"
popd

scoop bucket add sboot https://github.com/xfournet/scoop-sboot.git
scoop install sboot/sboot

Write-Host ""
Write-Host "Scoop bootstrapped. If everything is OK, execute 'sboot apply *' command. If you are unsure, first execute 'sboot apply -n *'"
