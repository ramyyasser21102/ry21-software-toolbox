BeforeAll {
    . "$PSScriptRoot/../../src/Versions/LatestKnownVersion.ps1"
    . "$PSScriptRoot/../../src/Versions/InstalledVersion.ps1"
}

Describe 'Get-LatestKnownVersion' {
    It 'reads the tag of the latest GitHub release' {
        Mock Invoke-RestMethod { [pscustomobject]@{ tag_name = 'v1.0.5' } }
        $source = [pscustomobject]@{ type = 'github-releases'; repository = 'owner/name' }

        Get-LatestKnownVersion -VersionSource $source | Should -Be 'v1.0.5'
    }

    It 'names the repository when GitHub cannot be reached' {
        Mock Invoke-RestMethod { throw 'offline' }
        $source = [pscustomobject]@{ type = 'github-releases'; repository = 'owner/name' }

        { Get-LatestKnownVersion -VersionSource $source } | Should -Throw "*'owner/name'*offline*"
    }

    It 'rejects an unsupported source type' {
        { Get-LatestKnownVersion -VersionSource ([pscustomobject]@{ type = 'carrier-pigeon' }) } | Should -Throw "*Unsupported version source type 'carrier-pigeon'*"
    }
}

Describe 'Get-InstalledVersion' {
    It 'returns nothing when the executable is not installed' {
        $detection = [pscustomobject]@{ type = 'file-version'; path = (Join-Path $TestDrive 'missing.exe') }

        Get-InstalledVersion -InstallDetection $detection | Should -BeNullOrEmpty
    }
}
