function Find-Entry {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Kind
    )

    $entry = Read-CatalogEntries -EntriesDirectory $EntriesDirectory | Where-Object { $_.kind -eq $Kind -and $_.name -eq $Name }
    if (-not $entry) {
        throw "No $Kind entry named '$Name'. Run 'toolbox list' to see the available entries."
    }
    return $entry
}
