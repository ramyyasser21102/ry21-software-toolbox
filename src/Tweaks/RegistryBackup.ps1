function Get-BackupFileName {
    param(
        [Parameter(Mandatory)][string]$EntryName,
        [Parameter(Mandatory)][string]$KeyPath,
        [Parameter(Mandatory)][datetime]$Timestamp
    )

    $safeKeyName = $KeyPath -replace '[^A-Za-z0-9]+', '_'
    return "$EntryName-$($Timestamp.ToString('yyyyMMdd-HHmmss'))-$safeKeyName.reg"
}

function Backup-AffectedKeys {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][string]$BackupDirectory,
        [Parameter(Mandatory)][datetime]$Timestamp
    )

    New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
    $keyPaths = @($Entry.affectedKeys) | Where-Object { $_ }
    foreach ($keyPath in $keyPaths) {
        if (-not (Test-RegistryKeyExists -KeyPath $keyPath)) { continue }
        $fileName = Get-BackupFileName -EntryName $Entry.name -KeyPath $keyPath -Timestamp $Timestamp
        $destinationPath = Join-Path $BackupDirectory $fileName
        Export-RegistryKey -KeyPath $keyPath -DestinationPath $destinationPath
        $destinationPath
    }
}
