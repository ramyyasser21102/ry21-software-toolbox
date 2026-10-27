BeforeAll {
    . "$PSScriptRoot/../../src/Versions/GitHubRelease.ps1"
    . "$PSScriptRoot/../../src/Updates/ReleaseAsset.ps1"
    . "$PSScriptRoot/../../src/Updates/Verification.ps1"
    . "$PSScriptRoot/../../src/Updates/PortableInstall.ps1"
    . "$PSScriptRoot/../../src/Updates/UpdateEntry.ps1"

    function Write-ToolArchive {
        param([string]$Directory)

        $buildFolder = Join-Path $Directory 'tool'
        New-Item -ItemType Directory -Path $buildFolder | Out-Null
        Set-Content -Path (Join-Path $buildFolder 'tool.exe') -Value 'new build'
        $fixtureArchivePath = Join-Path $Directory 'tool-x64.zip'
        Compress-Archive -Path $buildFolder -DestinationPath $fixtureArchivePath
        return $fixtureArchivePath
    }
}

Describe 'Update-SoftwareEntry' {
    BeforeEach {
        $workspace = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid()))
        $fixtureArchivePath = Write-ToolArchive -Directory $workspace
        $installDirectory = Join-Path $workspace 'installed'
        $entry = [pscustomobject]@{
            versionSource    = [pscustomobject]@{ repository = 'owner/tool' }
            delivery         = [pscustomobject]@{ assetName = 'tool-x64.zip' }
            verification     = [pscustomobject]@{ signer = 'none' }
            installDetection = [pscustomobject]@{ path = (Join-Path $installDirectory 'tool.exe') }
        }
        Mock Get-GitHubLatestRelease { [pscustomobject]@{ tag_name = 'v2.0.0' } }
        Mock Save-ReleaseAsset { Copy-Item -Path $fixtureArchivePath -Destination $DestinationPath }
    }

    It 'installs a download whose checksum matches' {
        $goodHash = (Get-FileHash -Path $fixtureArchivePath -Algorithm SHA256).Hash
        Mock ConvertTo-ReleaseAsset { [pscustomobject]@{ Name = 'tool-x64.zip'; Sha256 = $goodHash } }

        Update-SoftwareEntry -Entry $entry -WarningAction SilentlyContinue

        Get-Content (Join-Path $installDirectory 'tool.exe') | Should -Be 'new build'
    }

    It 'replaces an existing build and removes the old one' {
        New-Item -ItemType Directory -Path $installDirectory | Out-Null
        Set-Content -Path (Join-Path $installDirectory 'tool.exe') -Value 'old build'
        $goodHash = (Get-FileHash -Path $fixtureArchivePath -Algorithm SHA256).Hash
        Mock ConvertTo-ReleaseAsset { [pscustomobject]@{ Name = 'tool-x64.zip'; Sha256 = $goodHash } }

        Update-SoftwareEntry -Entry $entry -WarningAction SilentlyContinue

        Get-Content (Join-Path $installDirectory 'tool.exe') | Should -Be 'new build'
        "$installDirectory.previous" | Should -Not -Exist
    }

    It 'aborts on a bad checksum and installs nothing' {
        Mock ConvertTo-ReleaseAsset { [pscustomobject]@{ Name = 'tool-x64.zip'; Sha256 = ('0' * 64) } }

        { Update-SoftwareEntry -Entry $entry } | Should -Throw '*Checksum mismatch*'

        $installDirectory | Should -Not -Exist
    }

    It 'keeps the existing build when verification fails' {
        New-Item -ItemType Directory -Path $installDirectory | Out-Null
        Set-Content -Path (Join-Path $installDirectory 'tool.exe') -Value 'old build'
        Mock ConvertTo-ReleaseAsset { [pscustomobject]@{ Name = 'tool-x64.zip'; Sha256 = ('0' * 64) } }

        { Update-SoftwareEntry -Entry $entry } | Should -Throw

        Get-Content (Join-Path $installDirectory 'tool.exe') | Should -Be 'old build'
    }

    It 'aborts when the declared signer cannot be verified' {
        $goodHash = (Get-FileHash -Path $fixtureArchivePath -Algorithm SHA256).Hash
        Mock ConvertTo-ReleaseAsset { [pscustomobject]@{ Name = 'tool-x64.zip'; Sha256 = $goodHash } }
        Mock Assert-SignerMatches { throw 'Signer check failed' }

        { Update-SoftwareEntry -Entry $entry } | Should -Throw '*Signer check failed*'

        $installDirectory | Should -Not -Exist
    }
}
