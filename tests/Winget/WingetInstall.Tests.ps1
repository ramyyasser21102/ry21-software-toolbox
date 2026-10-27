BeforeAll {
    . "$PSScriptRoot/../../src/Winget/WingetOutput.ps1"
    . "$PSScriptRoot/../../src/Winget/WingetCommands.ps1"
    . "$PSScriptRoot/../../src/Updates/Elevation.ps1"
    . "$PSScriptRoot/../../src/Updates/WingetInstall.ps1"
}

Describe 'Test-NeedsElevation' {
    It 'asks for elevation only when the entry requires admin and the session is not elevated' -ForEach @(
        @{ RequiresAdmin = $true; IsElevated = $false; Expected = $true },
        @{ RequiresAdmin = $true; IsElevated = $true; Expected = $false },
        @{ RequiresAdmin = $false; IsElevated = $false; Expected = $false },
        @{ RequiresAdmin = $false; IsElevated = $true; Expected = $false }
    ) {
        Test-NeedsElevation -RequiresAdmin $RequiresAdmin -IsElevated $IsElevated | Should -Be $Expected
    }
}

Describe 'Install-WingetPackage' {
    BeforeEach {
        Mock Invoke-Winget { [pscustomobject]@{ ExitCode = 0; Output = '' } }
        Mock Invoke-ElevatedWinget { 0 }
    }

    It 'installs without elevation when the entry does not require admin' {
        Mock Test-IsElevated { $false }

        Install-WingetPackage -PackageId 'Example.Tool' -RequiresAdmin $false

        Should -Invoke Invoke-Winget -Times 1
        Should -Invoke Invoke-ElevatedWinget -Times 0
    }

    It 'elevates when the entry requires admin and the session is not elevated' {
        Mock Test-IsElevated { $false }

        Install-WingetPackage -PackageId 'Example.Tool' -RequiresAdmin $true

        Should -Invoke Invoke-ElevatedWinget -Times 1
        Should -Invoke Invoke-Winget -Times 0
    }

    It 'does not elevate again when already elevated' {
        Mock Test-IsElevated { $true }

        Install-WingetPackage -PackageId 'Example.Tool' -RequiresAdmin $true

        Should -Invoke Invoke-ElevatedWinget -Times 0
        Should -Invoke Invoke-Winget -Times 1
    }

    It 'throws with the exit code when winget fails' {
        Mock Test-IsElevated { $false }
        Mock Invoke-Winget { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        { Install-WingetPackage -PackageId 'Example.Tool' -RequiresAdmin $false } | Should -Throw '*exit code 1*'
    }
}

Describe 'Get-WingetLatestVersion' {
    It 'reads the version winget reports' {
        Mock Invoke-Winget { [pscustomobject]@{ ExitCode = 0; Output = "Version: 3.0.24`n" } }

        Get-WingetLatestVersion -PackageId 'VideoLAN.VLC' | Should -Be '3.0.24'
    }

    It 'names the package when winget cannot find it' {
        Mock Invoke-Winget { [pscustomobject]@{ ExitCode = 1; Output = 'No package found' } }

        { Get-WingetLatestVersion -PackageId 'No.Such' } | Should -Throw "*'No.Such'*"
    }
}
