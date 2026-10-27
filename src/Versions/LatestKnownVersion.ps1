function Get-GitHubLatestVersion {
    param([Parameter(Mandatory)][string]$Repository)

    $latestReleaseUrl = "https://api.github.com/repos/$Repository/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $latestReleaseUrl -Headers @{ 'User-Agent' = 'ry21-toolbox' } -ErrorAction Stop
    }
    catch {
        throw "Could not read the latest release of '$Repository' from GitHub: $($_.Exception.Message)"
    }
    return [string]$release.tag_name
}

function Get-LatestKnownVersion {
    param([Parameter(Mandatory)][psobject]$VersionSource)

    switch ($VersionSource.type) {
        'github-releases' { return Get-GitHubLatestVersion -Repository $VersionSource.repository }
        default { throw "Unsupported version source type '$($VersionSource.type)'" }
    }
}
