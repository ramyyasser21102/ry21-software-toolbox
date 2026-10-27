function Get-DeliveryErrors {
    param([Parameter(Mandatory)][psobject]$Delivery)

    $errors = Get-NotAllowedErrors -Label 'delivery type' -Values @($Delivery.type) -Allowed (Get-DeliveryTypes)
    if ($Delivery.type -eq 'portable-zip' -and [string]::IsNullOrWhiteSpace($Delivery.assetName)) {
        $errors += "delivery of type 'portable-zip' needs an 'assetName'"
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
