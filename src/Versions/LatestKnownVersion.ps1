function Get-GitHubLatestVersion {
    param([Parameter(Mandatory)][string]$Repository)

    return [string](Get-GitHubLatestRelease -Repository $Repository).tag_name
}

function Get-LatestKnownVersion {
    param([Parameter(Mandatory)][psobject]$VersionSource)

    switch ($VersionSource.type) {
        'github-releases' { return Get-GitHubLatestVersion -Repository $VersionSource.repository }
        'winget' { return Get-WingetLatestVersion -PackageId $VersionSource.packageId }
        default { throw "Unsupported version source type '$($VersionSource.type)'" }
    }
}
