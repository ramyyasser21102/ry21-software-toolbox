function Format-EntryListRows {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Entries)

    $Entries | Sort-Object -Property name | ForEach-Object {
        [pscustomobject]@{
            Name     = $_.name
            Kind     = $_.kind
            Category = $_.category
            Platform = $_.platforms -join ', '
            License  = $_.licenseType
        }
    }
}

function Invoke-ListCommand {
    param([Parameter(Mandatory)][string]$EntriesDirectory)

    $entries = Read-CatalogEntries -EntriesDirectory $EntriesDirectory
    Format-EntryListRows -Entries $entries | Format-Table -AutoSize
}
