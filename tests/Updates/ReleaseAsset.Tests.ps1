BeforeAll {
    . "$PSScriptRoot/../../src/Updates/ReleaseAsset.ps1"

    $sha256 = 'a' * 64
    $release = [pscustomobject]@{
        tag_name = 'v1.0.5'
        assets   = @(
            [pscustomobject]@{ name = 'tool-x64.zip'; digest = "sha256:$sha256"; browser_download_url = 'https://example.com/tool-x64.zip' },
            [pscustomobject]@{ name = 'no-digest.zip'; digest = $null; browser_download_url = 'https://example.com/no-digest.zip' }
        )
    }
}

Describe 'ConvertTo-ReleaseAsset' {
    It 'returns the download address and published SHA-256 of the named asset' {
        $asset = ConvertTo-ReleaseAsset -Release $release -AssetName 'tool-x64.zip'

        $asset.DownloadUrl | Should -Be 'https://example.com/tool-x64.zip'
        $asset.Sha256 | Should -Be $sha256
    }

    It 'throws when the release has no such asset' {
        { ConvertTo-ReleaseAsset -Release $release -AssetName 'missing.zip' } | Should -Throw "*no asset named 'missing.zip'*"
    }

    It 'refuses an asset with no published digest' {
        { ConvertTo-ReleaseAsset -Release $release -AssetName 'no-digest.zip' } | Should -Throw '*cannot be verified*'
    }
}
