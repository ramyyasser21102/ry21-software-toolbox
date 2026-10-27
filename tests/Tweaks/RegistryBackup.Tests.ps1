BeforeAll {
    . "$PSScriptRoot/../../src/Tweaks/RegistryAccess.ps1"
    . "$PSScriptRoot/../../src/Tweaks/RegistryBackup.ps1"

    $timestamp = [datetime]'2026-10-27T14:30:05'
    $entry = [pscustomobject]@{ name = 'example'; affectedKeys = @('HKCU\Software\Example', 'HKLM\Software\Missing') }
}

Describe 'Get-BackupFileName' {
    It 'is unique per entry, time and key' {
        Get-BackupFileName -EntryName 'example' -KeyPath 'HKCU\Software\Example' -Timestamp $timestamp | Should -Be 'example-20261027-143005-HKCU_Software_Example.reg'
    }
}

Describe 'Backup-AffectedKeys' {
    BeforeEach {
        Mock Test-RegistryKeyExists { $KeyPath -eq 'HKCU\Software\Example' }
        Mock Export-RegistryKey {}
    }

    It 'exports each key that exists and skips keys that do not' {
        $backups = Backup-AffectedKeys -Entry $entry -BackupDirectory (Join-Path $TestDrive 'backups') -Timestamp $timestamp

        Should -Invoke Export-RegistryKey -Times 1 -ParameterFilter { $KeyPath -eq 'HKCU\Software\Example' }
        $backups | Should -HaveCount 1
    }
}
