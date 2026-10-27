function Get-DeliveryErrors {
    param([Parameter(Mandatory)][psobject]$Delivery)

    $errors = Get-NotAllowedErrors -Label 'delivery type' -Values @($Delivery.type) -Allowed (Get-DeliveryTypes)
    if ($Delivery.type -eq 'portable-zip' -and [string]::IsNullOrWhiteSpace($Delivery.assetName)) {
        $errors += "delivery of type 'portable-zip' needs an 'assetName'"
    }
    if ($Delivery.type -eq 'winget' -and [string]::IsNullOrWhiteSpace($Delivery.packageId)) {
        $errors += "delivery of type 'winget' needs a 'packageId'"
    }
    return $errors
}

function Get-VerificationErrors {
    param([Parameter(Mandatory)][psobject]$Verification)

    $errors = Get-NotAllowedErrors -Label 'checksum type' -Values @($Verification.checksum) -Allowed (Get-ChecksumTypes)
    if ([string]::IsNullOrWhiteSpace($Verification.signer)) {
        $errors += "verification needs a 'signer': an expected signer name, or 'none' for an unsigned upstream"
    }
    return $errors
}

function Get-PortableVerificationErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    if ($Manifest.delivery.type -ne 'portable-zip') {
        return @()
    }
    if (-not $Manifest.verification) {
        return @("delivery of type 'portable-zip' needs a 'verification' block")
    }
    return Get-VerificationErrors -Verification $Manifest.verification
}

function Get-RequiresAdminErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $declaresRequiresAdmin = $Manifest.PSObject.Properties.Name -contains 'requiresAdmin'
    if ($declaresRequiresAdmin -and $Manifest.requiresAdmin -isnot [bool]) {
        return @("'requiresAdmin' must be true or false")
    }
    return @()
}
