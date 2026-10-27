function Assert-ChecksumMatches {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedSha256
    )

    $actualSha256 = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    if ($actualSha256 -ne $ExpectedSha256) {
        throw "Checksum mismatch: expected $ExpectedSha256 but the download is $actualSha256"
    }
}

function Get-SignatureError {
    param(
        [Parameter(Mandatory)][string]$Status,
        [AllowEmptyString()][string]$SignerSubject,
        [Parameter(Mandatory)][string]$ExpectedSigner
    )

    if ($Status -ne 'Valid') {
        return "Signature is not valid (status: $Status)"
    }
    if (-not $SignerSubject.Contains($ExpectedSigner)) {
        return "Signed by '$SignerSubject', expected a signer containing '$ExpectedSigner'"
    }
    return $null
}

function Assert-SignerMatches {
    param(
        [Parameter(Mandatory)][string]$ExecutablePath,
        [Parameter(Mandatory)][string]$ExpectedSigner
    )

    if ($ExpectedSigner -eq 'none') {
        Write-Warning "Upstream does not sign '$(Split-Path $ExecutablePath -Leaf)'; verified by checksum only"
        return
    }
    if (-not $IsWindows) {
        throw 'Authenticode signatures can only be verified on Windows'
    }
    $signature = Get-AuthenticodeSignature -FilePath $ExecutablePath
    $signerSubject = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { '' }
    $problem = Get-SignatureError -Status $signature.Status -SignerSubject $signerSubject -ExpectedSigner $ExpectedSigner
    if ($problem) {
        throw "Signer check failed for '$ExecutablePath': $problem"
    }
}
