function Get-ChangeActions {
    param([Parameter(Mandatory)][psobject]$Entry)

    if ($Entry.kind -eq 'registry-tweak') {
        return @{
            Show = { param($Path) Show-TweakChanges -Entry $Entry -RegFilePath $Path }.GetNewClosure()
            Run  = { param($Path) Import-RegFile -Path $Path }
        }
    }
    return @{
        Show = { param($Path) Show-ScriptPreview -Entry $Entry -ScriptPath $Path }.GetNewClosure()
        Run  = { param($Path) Invoke-ScriptFile -Path $Path }
    }
}

function Invoke-EntryChange {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][ValidateSet('apply', 'undo')][string]$Direction,
        [switch]$SkipConfirmation
    )

    Assert-EntryCanRun -Entry $Entry
    $actions = Get-ChangeActions -Entry $Entry
    $filePath = $Direction -eq 'apply' ? $Entry.applyFilePath : $Entry.undoFilePath
    & $actions.Show $filePath
    if (-not ($SkipConfirmation -or (Confirm-ToolboxAction -Question "Really $Direction '$($Entry.name)'?"))) {
        return "Cancelled: '$($Entry.name)' was not changed."
    }
    $backups = @()
    if ($Direction -eq 'apply') {
        $backups = @(Backup-AffectedKeys -Entry $Entry -BackupDirectory (Get-BackupDirectory) -Timestamp (Get-Date))
    }
    & $actions.Run $filePath
    return Format-ChangeResult -Entry $Entry -Direction $Direction -Backups $backups
}

function Format-ChangeResult {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][string]$Direction,
        [AllowEmptyCollection()][string[]]$Backups
    )

    if ($Direction -eq 'undo') {
        return "'$($Entry.name)' undone."
    }
    $backupText = $Backups ? "Backups: $($Backups -join ', '). " : ''
    return "'$($Entry.name)' applied. ${backupText}Reverse with: toolbox undo $($Entry.name)"
}

function Invoke-ApplyCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name,
        [switch]$SkipConfirmation
    )

    $entry = Find-Entry -EntriesDirectory $EntriesDirectory -Name $Name -Kind 'registry-tweak', 'script'
    return Invoke-EntryChange -Entry $entry -Direction 'apply' -SkipConfirmation:$SkipConfirmation
}

function Invoke-UndoCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name,
        [switch]$SkipConfirmation
    )

    $entry = Find-Entry -EntriesDirectory $EntriesDirectory -Name $Name -Kind 'registry-tweak', 'script'
    return Invoke-EntryChange -Entry $entry -Direction 'undo' -SkipConfirmation:$SkipConfirmation
}
