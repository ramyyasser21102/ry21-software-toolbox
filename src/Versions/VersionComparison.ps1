function ConvertTo-ComparableVersion {
    param([Parameter(Mandatory)][string]$VersionText)

    $versionPattern = '^\D*(\d+(?:\.\d+){0,3})'
    if ($VersionText -notmatch $versionPattern) {
        throw "Cannot read a version number from '$VersionText'"
    }
    $numericParts = @($Matches[1] -split '\.')
    $paddedParts = $numericParts + @('0') * (4 - $numericParts.Count)
    return [version]($paddedParts -join '.')
}

function Get-UpdateStatus {
    param(
        [AllowNull()][string]$InstalledVersion,
        [Parameter(Mandatory)][string]$LatestVersion
    )

    if ([string]::IsNullOrWhiteSpace($InstalledVersion)) {
        return 'not-installed'
    }
    $installed = ConvertTo-ComparableVersion -VersionText $InstalledVersion
    $latest = ConvertTo-ComparableVersion -VersionText $LatestVersion
    if ($installed -lt $latest) {
        return 'outdated'
    }
    return 'current'
}
