# Usage: sboot apply <configs> [options]
# Summary: Apply Sboot configuration
# Help: Apply the Sboot default configurations:
#      sboot apply
#
# To apply all configuration:
#      sboot apply *
#
# To apply a specific configuration:
#      sboot apply Win10Settings
#
# Options:
#   -v, --verbose             Log idempotent operations
#   -n, --dry-run             Modifications are logged but not executed

. "$( scoop prefix scoop )\lib\help.ps1"
. "$( scoop prefix scoop )\lib\getopt.ps1"

$opt, $apps, $err = getopt $args 'vn' 'verbose', 'dry-run'
if ($err) {
    "sboot apply: $err"; exit 1
}

. "$PSScriptRoot\..\lib\apply.ps1" $apps $opt.v $opt.n

& "$PSScriptRoot\..\config\config.ps1"