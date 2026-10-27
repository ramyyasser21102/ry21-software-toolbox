function Find-SoftwareEntry {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name
    )

    $entry = Read-CatalogEntries -EntriesDirectory $EntriesDirectory | Where-Object { $_.kind -eq 'software' -and $_.name -eq $Name }
    if (-not $entry) {
        throw "No software entry named '$Name'. Run 'toolbox list' to see the available entries."
    }
    return $entry
}

function Invoke-UpdateCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name
    )

    $entry = Find-SoftwareEntry -EntriesDirectory $EntriesDirectory -Name $Name
    $versionRow = Get-EntryVersionRow -Entry $entry
    if ($versionRow.Status -eq 'unknown') {
        throw "Cannot update '$Name': $($versionRow.Note)"
    }
    if ($versionRow.Status -eq 'current') {
        return "'$Name' is already up to date ($($versionRow.Installed))."
    }
    Update-SoftwareEntry -Entry $entry
    return "'$Name' updated to $($versionRow.Latest)."
}
