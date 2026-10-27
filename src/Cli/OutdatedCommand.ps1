function Get-EntryVersionRow {
    param([Parameter(Mandatory)][psobject]$Entry)

    $row = [ordered]@{ Name = $Entry.name; Installed = $null; Latest = $null; Status = 'unknown'; Note = $null }
    try {
        $row.Installed = Get-InstalledVersion -InstallDetection $Entry.installDetection
        $row.Latest = Get-LatestKnownVersion -VersionSource $Entry.versionSource
        $row.Status = Get-UpdateStatus -InstalledVersion $row.Installed -LatestVersion $row.Latest
    }
    catch {
        $row.Note = $_.Exception.Message
    }
    return [pscustomobject]$row
}

function Invoke-OutdatedCommand {
    param([Parameter(Mandatory)][string]$EntriesDirectory)

    $softwareEntries = Read-CatalogEntries -EntriesDirectory $EntriesDirectory | Where-Object kind -eq 'software'
    $softwareEntries | Sort-Object -Property name | ForEach-Object { Get-EntryVersionRow -Entry $_ } | Format-Table -AutoSize
}
