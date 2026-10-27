BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Catalog/SourceValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/DeliveryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/EntryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/CatalogLoader.ps1"

    function Write-Manifest {
        param([string]$Directory, [string]$FileName, [string]$Name, [string]$Category = 'monitoring')

        @{
            name        = $Name
            kind        = 'software'
            category    = $Category
            platforms   = @('windows')
            description = 'An example tool.'
            licenseType = 'open-source'
            upstreamUrl = 'https://example.com'
            versionSource    = @{ type = 'github-releases'; repository = 'owner/name' }
            installDetection = @{ type = 'file-version'; path = 'C:\\tool.exe' }
            delivery         = @{ type = 'portable-zip'; assetName = 'tool.zip' }
            verification     = @{ checksum = 'github-asset-digest'; signer = 'none' }
        } | ConvertTo-Json | Set-Content -Path (Join-Path $Directory $FileName)
    }
}

Describe 'Read-CatalogEntries' {
    BeforeEach { $entriesDirectory = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid())) }

    It 'loads every valid manifest' {
        Write-Manifest -Directory $entriesDirectory -FileName 'a.json' -Name 'alpha'
        Write-Manifest -Directory $entriesDirectory -FileName 'b.json' -Name 'beta'

        (Read-CatalogEntries -EntriesDirectory $entriesDirectory).name | Should -Be 'alpha', 'beta'
    }

    It 'names the file and the problem when a manifest is invalid' {
        Write-Manifest -Directory $entriesDirectory -FileName 'bad.json' -Name 'bad' -Category 'gaming'

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw "*bad.json*Unknown category 'gaming'*"
    }

    It 'reports malformed JSON with the file name' {
        Set-Content -Path (Join-Path $entriesDirectory 'broken.json') -Value '{ not json'

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw '*broken.json*not valid JSON*'
    }

    It 'rejects duplicate entry names' {
        Write-Manifest -Directory $entriesDirectory -FileName 'a.json' -Name 'same'
        Write-Manifest -Directory $entriesDirectory -FileName 'b.json' -Name 'same'

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw '*Duplicate entry names: same*'
    }
}
