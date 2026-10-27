BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Catalog/SourceValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/DeliveryValidation.ps1"
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
            versionSource    = [pscustomobject]@{ type = 'github-releases'; repository = 'owner/name' }
            installDetection = [pscustomobject]@{ type = 'file-version'; path = 'C:\\tool.exe' }
            delivery         = [pscustomobject]@{ type = 'portable-zip'; assetName = 'tool.zip' }
            verification     = [pscustomobject]@{ checksum = 'github-asset-digest'; signer = 'none'; }
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

Describe 'Get-ManifestErrors for version sources' {
    It 'rejects an unknown version source type' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.versionSource.type = 'carrier-pigeon'

        Get-ManifestErrors -Manifest $manifest | Should -Match "Unknown versionSource type 'carrier-pigeon'"
    }

    It 'requires a repository for github-releases' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.versionSource.repository = ''

        Get-ManifestErrors -Manifest $manifest | Should -Match "needs a 'repository'"
    }

    It 'requires a path for file-version detection' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.installDetection.path = ''

        Get-ManifestErrors -Manifest $manifest | Should -Match "needs a 'path'"
    }
}

Describe 'Get-ManifestErrors for delivery and verification' {
    It 'requires an asset name for a portable zip' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.delivery.assetName = ''

        Get-ManifestErrors -Manifest $manifest | Should -Match "needs an 'assetName'"
    }

    It 'requires the signer to be named or explicitly none' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.verification.signer = ''

        Get-ManifestErrors -Manifest $manifest | Should -Match "needs a 'signer'"
    }

    It 'rejects an unknown checksum type' {
        $manifest = Get-ValidSoftwareManifest
        $manifest.verification.checksum = 'trust-me'

        Get-ManifestErrors -Manifest $manifest | Should -Match "Unknown checksum type 'trust-me'"
    }
}

Describe 'Get-ManifestErrors for winget entries' {
    BeforeEach {
        $manifest = Get-ValidSoftwareManifest
        $manifest.versionSource = [pscustomobject]@{ type = 'winget'; packageId = 'Example.Tool' }
        $manifest.installDetection = [pscustomobject]@{ type = 'winget-list'; packageId = 'Example.Tool' }
        $manifest.delivery = [pscustomobject]@{ type = 'winget'; packageId = 'Example.Tool' }
        $manifest.PSObject.Properties.Remove('verification')
    }

    It 'accepts a winget entry without a verification block' {
        Get-ManifestErrors -Manifest $manifest | Should -BeNullOrEmpty
    }

    It 'requires a package id for each winget part' {
        $manifest.versionSource.packageId = ''
        $manifest.installDetection.packageId = ''
        $manifest.delivery.packageId = ''

        (Get-ManifestErrors -Manifest $manifest).Count | Should -Be 3
    }

    It 'rejects a requiresAdmin that is not true or false' {
        $manifest | Add-Member -NotePropertyName requiresAdmin -NotePropertyValue 'yes'

        Get-ManifestErrors -Manifest $manifest | Should -Match "'requiresAdmin' must be true or false"
    }

    It 'still requires verification for portable zips' {
        $manifest.delivery = [pscustomobject]@{ type = 'portable-zip'; assetName = 'tool.zip' }

        Get-ManifestErrors -Manifest $manifest | Should -Match "needs a 'verification' block"
    }
}
