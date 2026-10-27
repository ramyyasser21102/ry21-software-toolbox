BeforeAll {
    . "$PSScriptRoot/../../src/Winget/WingetOutput.ps1"
}

Describe 'ConvertFrom-WingetShowOutput' {
    It 'reads the version line of winget show' {
        $output = "Found VLC media player [VideoLAN.VLC]`nVersion: 3.0.24`nPublisher: VideoLAN`n"

        ConvertFrom-WingetShowOutput -Output $output | Should -Be '3.0.24'
    }

    It 'throws when no version is reported' {
        { ConvertFrom-WingetShowOutput -Output 'No package found' } | Should -Throw '*did not report a version*'
    }
}

Describe 'ConvertFrom-WingetListOutput' {
    It 'reads the installed version from the table row' {
        $output = "Name             Id            Version Available Source`n-----------------------------------------------------`nVLC media player VideoLAN.VLC  3.0.20  3.0.24    winget`n"

        ConvertFrom-WingetListOutput -Output $output -PackageId 'VideoLAN.VLC' | Should -Be '3.0.20'
    }

    It 'returns nothing when the package is not installed' {
        ConvertFrom-WingetListOutput -Output 'No installed package found matching input criteria.' -PackageId 'VideoLAN.VLC' | Should -BeNullOrEmpty
    }

    It 'does not match a package whose id only starts the same' {
        $output = "Name Id Version`n-----`nOther VideoLAN.VLCExtra 9.9.9 winget`n"

        ConvertFrom-WingetListOutput -Output $output -PackageId 'VideoLAN.VLC' | Should -BeNullOrEmpty
    }
}
