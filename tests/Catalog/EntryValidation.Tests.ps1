BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Catalog/EntryValidation.ps1"

    function Get-ValidSoftwareManifest {
        [pscustomobject]@{
            name        = 'example'
            kind        = 'software'
            category    = 'monitoring'
            platforms   = @('windows')
            description = 'An example tool.'
            licenseType = 'open-source'
            upstreamUrl = 'https://example.com'
        }
    }
}

Describe 'Get-ManifestErrors' {
    It 'accepts a valid software manifest' {
        Get-ManifestErrors -Manifest (Get-ValidSoftwareManifest) | Should -BeNullOrEmpty
    }

    It 'rejects an unknown category and names the allowed ones' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.category = 'gaming'

        Get-ManifestErrors -Manifest $manifest | Should -Contain "Unknown category 'gaming'. Allowed: monitoring, stress-test, benchmark, media, drivers, tweaks"
    }

    It 'rejects a missing required field' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.PSObject.Properties.Remove('description')

        Get-ManifestErrors -Manifest $manifest | Should -Contain "Missing required field 'description'"
    }

    It 'rejects a software manifest without a license type' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.PSObject.Properties.Remove('licenseType')

        Get-ManifestErrors -Manifest $manifest | Should -Contain "Missing required field 'licenseType'"
    }

    It 'rejects an empty platform list' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.platforms = @()

        Get-ManifestErrors -Manifest $manifest | Should -Contain "Missing required field 'platforms'"
    }

    It 'rejects an unknown platform' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.platforms = @('beos')

        Get-ManifestErrors -Manifest $manifest | Should -Match "Unknown platform 'beos'"
    }

    It 'rejects an unknown kind' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.kind = 'widget'

        Get-ManifestErrors -Manifest $manifest | Should -Match "Unknown kind 'widget'"
    }
}
