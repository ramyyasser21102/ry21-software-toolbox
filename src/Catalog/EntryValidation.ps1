function Get-ManifestErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $missingFieldErrors = Get-MissingFieldErrors -Manifest $Manifest
    if ($missingFieldErrors.Count -gt 0) {
        return $missingFieldErrors
    }
    return Get-InvalidValueErrors -Manifest $Manifest
}

function Get-MissingFieldErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $kind = [string]$Manifest.kind
    if ($kind -notin (Get-EntryKinds)) {
        return @("Unknown kind '$kind'. Allowed: $((Get-EntryKinds) -join ', ')")
    }
    $missingFields = Get-RequiredManifestFields -Kind $kind | Where-Object { Test-FieldIsBlank -Manifest $Manifest -Field $_ }
    return @($missingFields | ForEach-Object { "Missing required field '$_'" })
}

function Test-FieldIsBlank {
    param(
        [Parameter(Mandatory)][psobject]$Manifest,
        [Parameter(Mandatory)][string]$Field
    )

    $value = $Manifest.$Field
    if ($value -is [array]) {
        return $value.Count -eq 0
    }
    return [string]::IsNullOrWhiteSpace([string]$value)
}

function Get-InvalidValueErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $errors = @()
    $errors += Get-NotAllowedErrors -Label 'category' -Values @($Manifest.category) -Allowed (Get-EntryCategories)
    $errors += Get-NotAllowedErrors -Label 'platform' -Values @($Manifest.platforms) -Allowed (Get-EntryPlatforms)
    if ($Manifest.kind -eq 'software') {
        $errors += Get-NotAllowedErrors -Label 'licenseType' -Values @($Manifest.licenseType) -Allowed (Get-LicenseTypes)
    }
    return $errors
}

function Get-NotAllowedErrors {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string[]]$Values,
        [Parameter(Mandatory)][string[]]$Allowed
    )

    $notAllowedValues = $Values | Where-Object { $_ -notin $Allowed }
    return @($notAllowedValues | ForEach-Object { "Unknown $Label '$_'. Allowed: $($Allowed -join ', ')" })
}
