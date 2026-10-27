function Invoke-UpdateCommand {
    param(
        [Parameter(Mandatory)][string]$EntriesDirectory,
        [Parameter(Mandatory)][string]$Name
    )

    $entry = Find-Entry -EntriesDirectory $EntriesDirectory -Name $Name -Kind 'software'
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
