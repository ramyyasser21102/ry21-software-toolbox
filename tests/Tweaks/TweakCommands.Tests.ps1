BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Catalog/SourceValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/DeliveryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/TweakValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/EntryValidation.ps1"
    . "$PSScriptRoot/../../src/Catalog/TweakFiles.ps1"
    . "$PSScriptRoot/../../src/Catalog/CatalogLoader.ps1"
    . "$PSScriptRoot/../../src/Catalog/EntryLookup.ps1"
    . "$PSScriptRoot/../../src/Tweaks/RegFileText.ps1"
    . "$PSScriptRoot/../../src/Tweaks/RegistryAccess.ps1"
    . "$PSScriptRoot/../../src/Tweaks/RegistryBackup.ps1"
    . "$PSScriptRoot/../../src/Updates/Elevation.ps1"
    . "$PSScriptRoot/../../src/Tweaks/TweakRunner.ps1"
    . "$PSScriptRoot/../../src/Cli/TweakCommands.ps1"

    function Write-TweakFixture {
        param([string]$Directory, [bool]$WithUndoFile = $true, [bool]$RequiresAdmin = $false)

        $header = "Windows Registry Editor Version 5.00`r`n`r`n[HKEY_CURRENT_USER\Software\Example]`r`n"
        Set-Content -Path (Join-Path $Directory 'tweak.reg') -Value "$header`"Flag`"=dword:00000001"
        if ($WithUndoFile) { Set-Content -Path (Join-Path $Directory 'tweak-undo.reg') -Value "$header`"Flag`"=-" }
        @{
            name = 'example-tweak'; kind = 'registry-tweak'; category = 'tweaks'; platforms = @('windows')
            description = 'An example tweak.'; applyFile = 'tweak.reg'; undoFile = 'tweak-undo.reg'
            affectedKeys = @('HKCU\Software\Example'); requiresAdmin = $RequiresAdmin
        } | ConvertTo-Json | Set-Content -Path (Join-Path $Directory 'tweak.json')
    }
}

Describe 'Registry tweak entries' {
    BeforeEach { $entriesDirectory = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid())) }

    It 'are rejected when the undo file is missing' {
        Write-TweakFixture -Directory $entriesDirectory -WithUndoFile $false

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw "*undoFile 'tweak-undo.reg' but that file does not exist*"
    }

    It 'are rejected when the manifest does not name an undo file' {
        Write-TweakFixture -Directory $entriesDirectory
        $manifestPath = Join-Path $entriesDirectory 'tweak.json'
        (Get-Content $manifestPath -Raw | ConvertFrom-Json | Select-Object -ExcludeProperty undoFile) | ConvertTo-Json | Set-Content $manifestPath

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw "*Missing required field 'undoFile'*"
    }

    It 'are rejected when a .reg file changes a key that would not be backed up' {
        Write-TweakFixture -Directory $entriesDirectory
        Add-Content -Path (Join-Path $entriesDirectory 'tweak.reg') -Value '[HKEY_CURRENT_USER\Software\Unlisted]'

        { Read-CatalogEntries -EntriesDirectory $entriesDirectory } | Should -Throw '*would not be backed up*HKCU\Software\Unlisted*'
    }
}

Describe 'Invoke-ApplyCommand' {
    BeforeEach {
        $entriesDirectory = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid()))
        Write-TweakFixture -Directory $entriesDirectory
        $callLog = [System.Collections.Generic.List[string]]::new()
        Mock Test-IsElevated { $false }
        Mock Show-TweakChanges {}
        Mock Backup-AffectedKeys { $callLog.Add('backup'); 'C:\backups\one.reg' }
        Mock Import-RegFile { $callLog.Add("import $(Split-Path $Path -Leaf)") }
    }

    It 'asks first, then backs up, then applies' {
        Mock Confirm-ToolboxAction { $callLog.Add('confirm'); $true }

        Invoke-ApplyCommand -EntriesDirectory $entriesDirectory -Name 'example-tweak' | Should -Match 'applied'

        $callLog | Should -Be 'confirm', 'backup', 'import tweak.reg'
    }

    It 'changes nothing when the user declines' {
        Mock Confirm-ToolboxAction { $false }

        Invoke-ApplyCommand -EntriesDirectory $entriesDirectory -Name 'example-tweak' | Should -Match 'Cancelled'

        $callLog | Should -BeNullOrEmpty
    }

    It 'skips the question with -SkipConfirmation but still backs up' {
        Mock Confirm-ToolboxAction { throw 'should not ask' }

        Invoke-ApplyCommand -EntriesDirectory $entriesDirectory -Name 'example-tweak' -SkipConfirmation | Out-Null

        $callLog | Should -Be 'backup', 'import tweak.reg'
    }

    It 'refuses a requiresAdmin tweak from a non-elevated shell' {
        Write-TweakFixture -Directory $entriesDirectory -RequiresAdmin $true

        { Invoke-ApplyCommand -EntriesDirectory $entriesDirectory -Name 'example-tweak' -SkipConfirmation } | Should -Throw '*elevated*'
        $callLog | Should -BeNullOrEmpty
    }
}

Describe 'Invoke-UndoCommand' {
    It 'imports the undo file after confirmation' {
        $entriesDirectory = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid()))
        Write-TweakFixture -Directory $entriesDirectory
        Mock Test-IsElevated { $false }
        Mock Show-TweakChanges {}
        Mock Confirm-ToolboxAction { $true }
        Mock Import-RegFile {}

        Invoke-UndoCommand -EntriesDirectory $entriesDirectory -Name 'example-tweak' | Should -Match 'undone'

        Should -Invoke Import-RegFile -Times 1 -ParameterFilter { $Path -like '*tweak-undo.reg' }
    }
}
