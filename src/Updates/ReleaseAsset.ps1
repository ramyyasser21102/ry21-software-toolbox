function ConvertTo-ReleaseAsset {
    param(
        [Parameter(Mandatory)][psobject]$Release,
        [Parameter(Mandatory)][string]$AssetName
    )

    $asset = $Release.assets | Where-Object name -eq $AssetName
    if (-not $asset) {
        throw "Release '$($Release.tag_name)' has no asset named '$AssetName'"
    }
    if ($asset.digest -notmatch '^sha256:(?<hash>[0-9a-fA-F]{64})$') {
        throw "Asset '$AssetName' has no published SHA-256 digest, so it cannot be verified"
    }
    return [pscustomobject]@{ Name = $asset.name; DownloadUrl = $asset.browser_download_url; Sha256 = $Matches.hash }
}

function Save-ReleaseAsset {
    param(
        [Parameter(Mandatory)][psobject]$Asset,
        [Parameter(Mandatory)][string]$DestinationPath
    )

    try {
        Invoke-WebRequest -Uri $Asset.DownloadUrl -OutFile $DestinationPath -ErrorAction Stop
    }
    catch {
        throw "Could not download '$($Asset.Name)': $($_.Exception.Message)"
    }
}
