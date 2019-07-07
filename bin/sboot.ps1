param($cmd)

. "$PSScriptRoot\..\lib\commands.ps1"

$commands = commands
if ('--version' -contains $cmd -or (!$cmd -and '-v' -contains $args)) {
    scoop info sboot
} elseif (@($null, '--help', '/?') -contains $cmd -or $args[0] -contains '-h') {
    exec 'help' $args
} elseif ($commands -contains $cmd) {
    exec $cmd $args
} else {
    "sboot: '$cmd' isn't a sboot command. See 'sboot help'."; exit 1
}
