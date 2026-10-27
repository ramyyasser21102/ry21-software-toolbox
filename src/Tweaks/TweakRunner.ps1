function Get-BackupDirectory {
    $localData = [Environment]::GetFolderPath('LocalApplicationData')
    return Join-Path $localData 'RY21Toolbox/backups'
}

function Confirm-ToolboxAction {
    param([Parameter(Mandatory)][string]$Question)

    return (Read-Host "$Question [y/N]") -match '^(y|yes)$'
}

function Get-CurrentPlatform {
    if ($IsWindows) { return 'windows' }
    return $IsLinux ? 'linux' : 'macos'
}

function Test-PlatformSupported {
    param(
        [Parameter(Mandatory)][string[]]$Platforms,
        [Parameter(Mandatory)][string]$CurrentPlatform
    )

    return $CurrentPlatform -in $Platforms
}

function Assert-EntryCanRun {
    param([Parameter(Mandatory)][psobject]$Entry)

    $currentPlatform = Get-CurrentPlatform
    if (-not (Test-PlatformSupported -Platforms @($Entry.platforms) -CurrentPlatform $currentPlatform)) {
        throw "'$($Entry.name)' is for $(@($Entry.platforms) -join ', ') but this machine is $currentPlatform."
    }
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
