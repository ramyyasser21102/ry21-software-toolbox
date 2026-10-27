BeforeAll {
    . "$PSScriptRoot/../../src/Updates/Verification.ps1"
}

Describe 'Assert-ChecksumMatches' {
    It 'passes when the file matches the expected SHA-256' {
        $path = Join-Path $TestDrive 'file.bin'
        Set-Content -Path $path -Value 'content'
        $hash = (Get-FileHash -Path $path -Algorithm SHA256).Hash

        { Assert-ChecksumMatches -Path $path -ExpectedSha256 $hash } | Should -Not -Throw
    }

    It 'throws and names both hashes when the file differs' {
        $path = Join-Path $TestDrive 'file.bin'
        Set-Content -Path $path -Value 'content'

        { Assert-ChecksumMatches -Path $path -ExpectedSha256 ('0' * 64) } | Should -Throw '*Checksum mismatch*'
    }
}

Describe 'Get-SignatureError' {
    It 'accepts a valid signature from the expected signer' {
        Get-SignatureError -Status 'Valid' -SignerSubject 'CN=Example Corp, O=Example' -ExpectedSigner 'Example Corp' | Should -BeNullOrEmpty
    }

    It 'rejects a signature that is not valid' {
        Get-SignatureError -Status 'HashMismatch' -SignerSubject 'CN=Example Corp' -ExpectedSigner 'Example Corp' | Should -Match 'not valid'
    }

    It 'rejects a valid signature from the wrong signer' {
        Get-SignatureError -Status 'Valid' -SignerSubject 'CN=Someone Else' -ExpectedSigner 'Example Corp' | Should -Match "expected a signer containing 'Example Corp'"
    }

    It 'rejects a file with no signature at all' {
        Get-SignatureError -Status 'NotSigned' -SignerSubject '' -ExpectedSigner 'Example Corp' | Should -Match 'NotSigned'
    }
}

Describe 'Assert-SignerMatches' {
    It 'passes with a warning when the entry declares an unsigned upstream' {
        { Assert-SignerMatches -ExecutablePath 'tool.exe' -ExpectedSigner 'none' -WarningAction SilentlyContinue } | Should -Not -Throw
    }

    It 'cannot verify a named signer off Windows' -Skip:$IsWindows {
        { Assert-SignerMatches -ExecutablePath 'tool.exe' -ExpectedSigner 'Example Corp' } | Should -Throw '*only be verified on Windows*'
    }
}
