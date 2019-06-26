$scoopRootDir = scoop prefix scoop
. "$scoopRootDir\lib\core.ps1"
. "$scoopRootDir\lib\buckets.ps1"

. "$( sboot_mod "Utils" )"

Function EnsureScoopConfig([String]$ScoopConfig) {
    $scoopConf = ConvertFrom-Json $ScoopConfig

    foreach ($bucketSpec in $scoopConf.buckets) {
        if ($bucketSpec -ne "" -and !($bucketSpec -like "#*")) {
            EnsureScoopBucket $bucketSpec
        }
    }

    foreach ($appSpec in $scoopConf.apps) {
        if ($appSpec -ne "" -and !($appSpec -like "#*")) {
            EnsureScoopApp $appSpec
        }
    }

    foreach ($extSpec in $scoopConf.exts) {
        if ($extSpec -ne "" -and !($extSpec -like "#*")) {
            EnsureScoopExt $extSpec
        }
    }
}

Function EnsureScoopBucket($bucketSpec) {
    if ($bucketSpec -match "^([^@]+)(@(.+))?$") {
        $bucketName = $Matches[1]
        $bucketRepo = $Matches[3]

        $dir = Find-BucketDirectory $bucketName -Root
        if (test-path $dir) {
            LogIdempotent "Scoop bucket '$bucketName' already exists"
        } else {
            DoUpdate "Scoop bucket '$bucketSpec' added" {
                scoop bucket add $bucketName $bucketRepo
            }
        }
    } else {
        LogWarn "Invalid bucket : $bucketSpec"
    }
}

Function ScoopIsInstalled($appName) {
    return installed $appName
}

Function EnsureScoopApp($appSpec) {
    if ($appSpec -match "^((.+)/)?([^@/]+)(@(.+))?$") {
        $appRepo = $Matches[2]
        $appName = $Matches[3]
        $appVersion = $Matches[5]

        if (installed $appName) {
            LogIdempotent "Scoop app '$( $appName )' is already installed"
        } else {
            DoUpdate "Scoop app '$appSpec' installed" {
                scoop install $appSpec
            }
        }
    } else {
        LogWarn "Invalid application : $App"
    }
}

Function EnsureScoopExt($extSpec) {
    $scriptLines = @(". `"`$( sboot_mod `"ScoopExt-$($extSpec.name)`" )`"")
    $scriptLines += $extSpec.script
    Invoke-Expression ($scriptLines -join "`r`n")
}
