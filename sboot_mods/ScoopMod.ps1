$scoopRootDir = scoop prefix scoop
. "$scoopRootDir\lib\core.ps1"
. "$scoopRootDir\lib\buckets.ps1"
. "$scoopRootDir\lib\manifest.ps1"
. "$scoopRootDir\lib\versions.ps1"

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
        $version = Select-CurrentVersion $extraApp $false
        $install_info = install_info $extraApp $version $false
        $bucket = $install_info.bucket
        if ($bucket -eq "main") {
            $bucket = ""
        } else {
            $bucket = "$bucket/"
        }

        LogWarn "Application '$bucket$extraApp' is not referenced in sboot configuration"
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
        $appBucket = $Matches[2]
        if (!$appBucket) {
            $appBucket = "main"
        }
        $appName = $Matches[3]
        $appVersion = $Matches[5]

        if (installed $appName) {
            LogIdempotent "Scoop app '$( $appName )' is already installed"

            $ver = Select-CurrentVersion $appName $false
            $install_info = install_info $appName $ver $false
            if ($install_info.bucket -ne $appBucket) {
                LogWarn "Scoop app '$appName' is from bucket '$( $install_info.bucket )' but declared in bucket '$appBucket' in sboot"
            }

            if ($appVersion -and ($appVersion -ne $ver)) {
                LogWarn "Scoop app '$appName' version is '$ver' but declared with version '$appVersion' in sboot"
            }
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
