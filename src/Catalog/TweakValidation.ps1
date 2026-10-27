function Get-TweakErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $errors = @()
    $badKeys = @($Manifest.affectedKeys) | Where-Object { $_ -notmatch '^(HKCU|HKLM)\\.+' }
    foreach ($badKey in $badKeys) {
        $errors += "affectedKeys entry '$badKey' must start with HKCU\ or HKLM\"
    }
    return $errors
}
