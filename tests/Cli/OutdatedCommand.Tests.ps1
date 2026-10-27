BeforeAll {
    . "$PSScriptRoot/../../src/Versions/VersionComparison.ps1"
    . "$PSScriptRoot/../../src/Versions/LatestKnownVersion.ps1"
    . "$PSScriptRoot/../../src/Versions/InstalledVersion.ps1"
    . "$PSScriptRoot/../../src/Cli/OutdatedCommand.ps1"

    $entry = [pscustomobject]@{ name = 'example'; installDetection = [pscustomobject]@{}; versionSource = [pscustomobject]@{} }
}

Describe 'Get-EntryVersionRow' {
    It 'reports an older installed version as outdated' {
        Mock Get-InstalledVersion { '1.0.4.0' }
        Mock Get-LatestKnownVersion { 'v1.0.5' }

        $row = Get-EntryVersionRow -Entry $entry

        $row.Status | Should -Be 'outdated'
        $row.Latest | Should -Be 'v1.0.5'
    }

    It 'reports a matching version as current' {
        Mock Get-InstalledVersion { '1.0.5.0' }
        Mock Get-LatestKnownVersion { 'v1.0.5' }

        (Get-EntryVersionRow -Entry $entry).Status | Should -Be 'current'
    }

    It 'keeps going with an explanatory note when the upstream cannot be read' {
        Mock Get-InstalledVersion { $null }
        Mock Get-LatestKnownVersion { throw 'GitHub unreachable' }

        $row = Get-EntryVersionRow -Entry $entry

        $row.Status | Should -Be 'unknown'
        $row.Note | Should -Match 'GitHub unreachable'
    }
}
