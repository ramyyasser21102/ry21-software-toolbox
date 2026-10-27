BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Catalog/SourceValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/TweakValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/DeliveryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/EntryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/ChangeFiles.ps1"
    . "$PSScriptRoot/../../src/Tweaks/RegFileText.ps1"
    . "$PSScriptRoot/../../src/Catalog/CatalogLoader.ps1"

    $entriesDirectory = Join-Path $PSScriptRoot '../../entries'
}

Describe 'Shipped entries' {
    It 'all load and validate' {
        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Not -Throw
    }

    It 'include HWiNFO as a winget entry that requires admin' {
        $hwinfo = Read-CatalogEntries -EntriesDirectory $entriesDirectory | Where-Object name -eq 'hwinfo'

        $hwinfo.delivery.type | Should -Be 'winget'
        $hwinfo.requiresAdmin | Should -BeTrue
    }
}
