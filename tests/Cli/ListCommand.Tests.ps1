BeforeAll {
    . "$PSScriptRoot/../../src/Cli/ListCommand.ps1"
}

Describe 'Format-EntryListRows' {
    It 'shows platform, category and license type, sorted by name' {
        $entries = @(
            [pscustomobject]@{ name = 'zeta'; kind = 'software'; category = 'media'; platforms = @('windows', 'linux'); licenseType = 'freeware' },
            [pscustomobject]@{ name = 'alpha'; kind = 'software'; category = 'monitoring'; platforms = @('windows'); licenseType = 'open-source' }
        )

        $rows = Format-EntryListRows -Entries $entries

        $rows.Name | Should -Be 'alpha', 'zeta'
        $rows[0].License | Should -Be 'open-source'
        $rows[1].Platform | Should -Be 'windows, linux'
    }
}
