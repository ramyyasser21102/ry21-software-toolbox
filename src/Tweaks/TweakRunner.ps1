function Get-BackupDirectory {
    $localData = [Environment]::GetFolderPath('LocalApplicationData')
    return Join-Path $localData 'RY21Toolbox/backups'
}

function Confirm-ToolboxAction {
    param([Parameter(Mandatory)][string]$Question)

    return (Read-Host "$Question [y/N]") -match '^(y|yes)$'
}

function Assert-TweakCanRun {
    param([Parameter(Mandatory)][psobject]$Entry)

    if (Test-NeedsElevation -RequiresAdmin ([bool]$Entry.requiresAdmin) -IsElevated (Test-IsElevated)) {
        throw "'$($Entry.name)' changes machine-wide settings. Re-run this command from an elevated (administrator) PowerShell."
    }
}

function Show-TweakChanges {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][string]$RegFilePath
    )

    Write-Host "'$($Entry.name)': $($Entry.description)"
    Write-Host 'This will change:'
    Get-RegFileChangeLines -RegFileText (Get-Content -LiteralPath $RegFilePath -Raw) | ForEach-Object { Write-Host "  $_" }
}
