function Add-ChangeFilePaths {
    param(
        [Parameter(Mandatory)][psobject]$Manifest,
        [Parameter(Mandatory)][string]$ManifestPath
    )

    $manifestFolder = Split-Path $ManifestPath -Parent
    foreach ($field in 'applyFile', 'undoFile') {
        $filePath = Join-Path $manifestFolder $Manifest.$field
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw "Manifest '$ManifestPath' names $field '$($Manifest.$field)' but that file does not exist"
        }
        $Manifest | Add-Member -NotePropertyName "${field}Path" -NotePropertyValue $filePath -Force
    }
    if ($Manifest.kind -eq 'registry-tweak') {
        Assert-TweakFilesStayInsideAffectedKeys -Manifest $Manifest -ManifestPath $ManifestPath
    }
}

function Assert-TweakFilesStayInsideAffectedKeys {
    param(
        [Parameter(Mandatory)][psobject]$Manifest,
        [Parameter(Mandatory)][string]$ManifestPath
    )

    foreach ($filePath in $Manifest.applyFilePath, $Manifest.undoFilePath) {
        $uncovered = Get-UncoveredKeys -RegFileText (Get-Content -LiteralPath $filePath -Raw) -AffectedKeys @($Manifest.affectedKeys)
        if ($uncovered) {
            throw "Manifest '$ManifestPath': '$(Split-Path $filePath -Leaf)' changes keys not listed in affectedKeys, so they would not be backed up: $($uncovered -join ', ')"
        }
    }
}
