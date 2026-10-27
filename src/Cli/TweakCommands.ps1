function Invoke-ApplyCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name,
        [switch]$SkipConfirmation
    )

    $entry = Find-Entry -EntriesDirectory $EntriesDirectory -Name $Name -Kind 'registry-tweak'
    Assert-TweakCanRun -Entry $entry
    Show-TweakChanges -Entry $entry -RegFilePath $entry.applyFilePath
    if (-not ($SkipConfirmation -or (Confirm-ToolboxAction -Question 'Apply these changes?'))) {
        return "Cancelled: '$Name' was not applied."
    }
    $backups = @(Backup-AffectedKeys -Entry $entry -BackupDirectory (Get-BackupDirectory) -Timestamp (Get-Date))
    Import-RegFile -Path $entry.applyFilePath
    return "'$Name' applied. Backups: $(if ($backups) { $backups -join ', ' } else { 'none needed (keys did not exist)' }). Reverse with: toolbox undo $Name"
}

function Invoke-UndoCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name,
        [switch]$SkipConfirmation
    )

    $entry = Find-Entry -EntriesDirectory $EntriesDirectory -Name $Name -Kind 'registry-tweak'
    Assert-TweakCanRun -Entry $entry
    Show-TweakChanges -Entry $entry -RegFilePath $entry.undoFilePath
    if (-not ($SkipConfirmation -or (Confirm-ToolboxAction -Question 'Undo these changes?'))) {
        return "Cancelled: '$Name' was not undone."
    }
    Import-RegFile -Path $entry.undoFilePath
    return "'$Name' undone."
}
