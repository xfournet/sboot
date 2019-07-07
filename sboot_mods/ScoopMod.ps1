$scoopRootDir = scoop prefix scoop
. "$scoopRootDir\lib\core.ps1"
. "$scoopRootDir\lib\buckets.ps1"

Function EnsureScoopConfig([String]$ScoopConfig) {
    $scoopConf = ConvertFrom-Json $ScoopConfig

    $allConfiguredBuckets = @()
    foreach ($bucketSpec in $scoopConf.buckets) {
        if ($bucketSpec -ne "" -and !($bucketSpec -like "#*")) {
            $bucketName = EnsureScoopBucket $bucketSpec
            if ($bucketName) {
                $allConfiguredBuckets += $bucketName
            }
        }
    }
    foreach ($extraBucket in (Get-LocalBucket | Where-Object { $_ -notin $allConfiguredBuckets })) {
        LogWarn "Bucket '$extraBucket' is not referenced in sboot configuration"
    }


    $allConfiguredApps = @()
    foreach ($appSpec in $scoopConf.apps) {
        if ($appSpec -ne "" -and !($appSpec -like "#*")) {
            $appName = EnsureScoopApp $appSpec
            if ($appName) {
                $allConfiguredApps += $appName
            }
        }
    }
    foreach ($extraApp in (installed_apps($false) | Where-Object { $_ -notin $allConfiguredApps })) {
        LogWarn "Application '$extraApp' is not referenced in sboot configuration"
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
        if (Test-Path -LiteralPath $dir) {
            LogIdempotent "Scoop bucket '$bucketName' already exists"
        } else {
            DoUpdate "Scoop bucket '$bucketSpec' added" {
                scoop bucket add $bucketName $bucketRepo
            }
        }
        return $bucketName
    } else {
        LogWarn "Invalid bucket : $bucketSpec"
    }
}

Function EnsureScoopApp($appSpec) {
    if ($appSpec -match "^((.+)/)?([^@/]+)(@(.+))?$") {
        # $appRepo = $Matches[2]
        $appName = $Matches[3]
        # $appVersion = $Matches[5]

        if (installed $appName) {
            LogIdempotent "Scoop app '$( $appName )' is already installed"
        } else {
            DoUpdate "Scoop app '$appSpec' installed" {
                scoop install $appSpec
            }
        }
        return $appName
    } else {
        LogWarn "Invalid application : $appSpec"
    }
}

Function EnsureScoopExt($extSpec) {
    if ($extSpec.app -match "^((.+)/)?([^@/]+)$") {
        $extRepo = $Matches[2]
        $extAppName = $Matches[3]

        if (!$extRepo) {
            $extRepo = "sboot"
        }

        $params = @{ }
        if ($extSpec.parameters) {
            $extSpec.parameters.PSObject.Properties | Foreach-Object { $params[$_.Name] = $_.Value }
        }

        if (installed $extAppName) {
            $params["AppDir"] = $( scoop prefix $extAppName )
            & {
                . "$( sboot_mod "$extRepo/ScoopExt-$( $extAppName )" )"
                AppInstalled @params
            }
        } else {
            & {
                . "$( sboot_mod "$extRepo/ScoopExt-$( $extAppName )" )"
                AppUninstalled @params
            }
        }
    } else {
        LogWarn "Invalid extension : $( $extSpec.name )"
    }
}
