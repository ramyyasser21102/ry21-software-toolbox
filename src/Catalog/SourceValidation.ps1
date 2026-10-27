function Get-SourceErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    if ($Manifest.kind -ne 'software') {
        return @()
    }
    $errors = @()
    $errors += Get-VersionSourceErrors -VersionSource $Manifest.versionSource
    $errors += Get-InstallDetectionErrors -InstallDetection $Manifest.installDetection
    return $errors
}

function Get-VersionSourceErrors {
    param([Parameter(Mandatory)][psobject]$VersionSource)

    $errors = Get-NotAllowedErrors -Label 'versionSource type' -Values @($VersionSource.type) -Allowed (Get-VersionSourceTypes)
    if ($VersionSource.type -eq 'github-releases' -and [string]::IsNullOrWhiteSpace($VersionSource.repository)) {
        $errors += "versionSource of type 'github-releases' needs a 'repository' (owner/name)"
    }
    return $errors
}

function Get-InstallDetectionErrors {
    param([Parameter(Mandatory)][psobject]$InstallDetection)

    $errors = Get-NotAllowedErrors -Label 'installDetection type' -Values @($InstallDetection.type) -Allowed (Get-InstallDetectionTypes)
    if ($InstallDetection.type -eq 'file-version' -and [string]::IsNullOrWhiteSpace($InstallDetection.path)) {
        $errors += "installDetection of type 'file-version' needs a 'path'"
    }
    return $errors
}
