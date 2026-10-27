function Read-CatalogEntries {
    param([Parameter(Mandatory)][string]$EntriesDirectory)

    $manifestFiles = Get-ChildItem -Path $EntriesDirectory -Filter '*.json' -Recurse -File
    $entries = @($manifestFiles | ForEach-Object { Read-EntryManifest -Path $_.FullName })
    Assert-EntryNamesAreUnique -Entries $entries
    return $entries
}

function Read-EntryManifest {
    param([Parameter(Mandatory)][string]$Path)

    try {
        $manifest = Get-Content -Path $Path -Raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "Manifest '$Path' is not valid JSON: $($_.Exception.Message)"
    }
    $errors = Get-ManifestErrors -Manifest $manifest
    if ($errors.Count -gt 0) {
        throw "Manifest '$Path' is invalid:`n - $($errors -join "`n - ")"
    }
    if ($manifest.kind -in 'registry-tweak', 'script') {
        Add-ChangeFilePaths -Manifest $manifest -ManifestPath $Path
    }
    return $manifest
}

function Assert-EntryNamesAreUnique {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Entries)

    $duplicateNames = $Entries | Group-Object -Property name | Where-Object Count -gt 1 | ForEach-Object Name
    if ($duplicateNames) {
        throw "Duplicate entry names: $($duplicateNames -join ', ')"
    }
}
