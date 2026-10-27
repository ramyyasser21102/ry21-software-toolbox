function Get-FileInstalledVersion {
    param([Parameter(Mandatory)][string]$PathTemplate)

    $executablePath = [Environment]::ExpandEnvironmentVariables($PathTemplate)
    if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
        return $null
    }
    return (Get-Item -LiteralPath $executablePath).VersionInfo.FileVersion
}

function Get-InstalledVersion {
    param([Parameter(Mandatory)][psobject]$InstallDetection)

    switch ($InstallDetection.type) {
        'file-version' { return Get-FileInstalledVersion -PathTemplate $InstallDetection.path }
        default { throw "Unsupported install detection type '$($InstallDetection.type)'" }
    }
}
