BeforeAll {
    . "$PSScriptRoot/../../src/Versions/VersionComparison.ps1"
}

Describe 'ConvertTo-ComparableVersion' {
    It 'treats a tag with a v prefix like a plain version' {
        ConvertTo-ComparableVersion -VersionText 'v1.0.5' | Should -Be ([version]'1.0.5.0')
    }

    It 'pads short versions so 1.0.5 equals 1.0.5.0' {
        ConvertTo-ComparableVersion -VersionText '1.0.5.0' | Should -Be (ConvertTo-ComparableVersion -VersionText '1.0.5')
    }

    It 'ignores a prerelease suffix' {
        ConvertTo-ComparableVersion -VersionText '2.1.0-beta' | Should -Be ([version]'2.1.0.0')
    }

    It 'throws on text with no version number' {
        { ConvertTo-ComparableVersion -VersionText 'latest' } | Should -Throw "*Cannot read a version number from 'latest'*"
    }
}

Describe 'Get-UpdateStatus' {
    It 'reports not-installed when nothing is installed' {
        Get-UpdateStatus -InstalledVersion $null -LatestVersion 'v1.0.5' | Should -Be 'not-installed'
    }

    It 'reports outdated when the installed version is older' {
        Get-UpdateStatus -InstalledVersion '1.0.4.0' -LatestVersion 'v1.0.5' | Should -Be 'outdated'
    }

    It 'reports current when the versions match' {
        Get-UpdateStatus -InstalledVersion '1.0.5.0' -LatestVersion 'v1.0.5' | Should -Be 'current'
    }

    It 'reports current when the installed version is newer' {
        Get-UpdateStatus -InstalledVersion '1.1.0.0' -LatestVersion 'v1.0.5' | Should -Be 'current'
    }
}
