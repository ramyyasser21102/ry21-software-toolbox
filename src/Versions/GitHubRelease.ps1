function Get-GitHubLatestRelease {
    param([Parameter(Mandatory)][string]$Repository)

    $latestReleaseUrl = "https://api.github.com/repos/$Repository/releases/latest"
    try {
        return Invoke-RestMethod -Uri $latestReleaseUrl -Headers @{ 'User-Agent' = 'ry21-toolbox' } -ErrorAction Stop
    }
    catch {
        throw "Could not read the latest release of '$Repository' from GitHub: $($_.Exception.Message)"
    }
}
