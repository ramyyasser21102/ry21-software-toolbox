function Get-BuildRoot {
    param([Parameter(Mandatory)][string]$ExtractedDirectory)

    $children = @(Get-ChildItem -Path $ExtractedDirectory)
    $hasSingleFolderOnly = $children.Count -eq 1 -and $children[0].PSIsContainer
    if ($hasSingleFolderOnly) {
        return $children[0].FullName
    }
    return $ExtractedDirectory
}

function Install-StagedBuild {
    param(
        [Parameter(Mandatory)][string]$BuildRoot,
        [Parameter(Mandatory)][string]$InstallDirectory
    )

    $previousBuild = "$InstallDirectory.previous"
    $hasPreviousBuild = Test-Path -LiteralPath $InstallDirectory
    New-Item -ItemType Directory -Path (Split-Path $InstallDirectory -Parent) -Force | Out-Null
    if ($hasPreviousBuild) {
        Move-Item -LiteralPath $InstallDirectory -Destination $previousBuild -Force
    }
    try {
        Move-Item -LiteralPath $BuildRoot -Destination $InstallDirectory
    }
    catch {
        if ($hasPreviousBuild) { Move-Item -LiteralPath $previousBuild -Destination $InstallDirectory }
        throw "Could not install into '$InstallDirectory': $($_.Exception.Message)"
    }
    if ($hasPreviousBuild) { Remove-Item -LiteralPath $previousBuild -Recurse -Force }
}
