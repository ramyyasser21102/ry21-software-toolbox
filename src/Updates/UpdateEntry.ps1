function Get-InstallDirectory {
    param([Parameter(Mandatory)][psobject]$Entry)

    $detectedPath = [Environment]::ExpandEnvironmentVariables($Entry.installDetection.path)
    return Split-Path $detectedPath -Parent
}

function Get-VerifiedBuildRoot {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][string]$StagingDirectory
    )

    $release = Get-GitHubLatestRelease -Repository $Entry.versionSource.repository
    $asset = ConvertTo-ReleaseAsset -Release $release -AssetName $Entry.delivery.assetName
    $archivePath = Join-Path $StagingDirectory $asset.Name
    Save-ReleaseAsset -Asset $asset -DestinationPath $archivePath
    Assert-ChecksumMatches -Path $archivePath -ExpectedSha256 $asset.Sha256
    $extractedDirectory = Join-Path $StagingDirectory 'extracted'
    Expand-Archive -Path $archivePath -DestinationPath $extractedDirectory
    $buildRoot = Get-BuildRoot -ExtractedDirectory $extractedDirectory
    $signedFile = Join-Path $buildRoot (Split-Path $Entry.installDetection.path -Leaf)
    Assert-SignerMatches -ExecutablePath $signedFile -ExpectedSigner $Entry.verification.signer
    return $buildRoot
}

function Install-PortableEntry {
    param([Parameter(Mandatory)][psobject]$Entry)

    $stagingDirectory = Join-Path ([IO.Path]::GetTempPath()) "ry21-toolbox-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $stagingDirectory | Out-Null
    try {
        $buildRoot = Get-VerifiedBuildRoot -Entry $Entry -StagingDirectory $stagingDirectory
        Install-StagedBuild -BuildRoot $buildRoot -InstallDirectory (Get-InstallDirectory -Entry $Entry)
    }
    finally {
        # Best-effort: a leftover temp folder must not mask the real outcome of the update.
        Remove-Item -LiteralPath $stagingDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Update-SoftwareEntry {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][psobject]$Entry)

    if (-not $PSCmdlet.ShouldProcess($Entry.name, 'Download, verify and install the latest build')) {
        return
    }
    switch ($Entry.delivery.type) {
        'portable-zip' { Install-PortableEntry -Entry $Entry }
        'winget' { Install-WingetPackage -PackageId $Entry.delivery.packageId -RequiresAdmin ([bool]$Entry.requiresAdmin) }
        default { throw "Unsupported delivery type '$($Entry.delivery.type)'" }
    }
}
