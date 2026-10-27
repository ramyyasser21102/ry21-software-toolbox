BeforeAll {
    . "$PSScriptRoot/../../src/Catalog/EntryVocabulary.ps1"
    . "$PSScriptRoot/../../src/Tweaks/ScriptRunner.ps1"
    . "$PSScriptRoot/../../src/Tweaks/TweakRunner.ps1"
}

Describe 'Get-ScriptCommand' {
    It 'runs a ps1 with PowerShell without loading the user profile' {
        $command = Get-ScriptCommand -FilePath 'task.ps1' -PowerShellPath '/usr/bin/pwsh'

        $command.Program | Should -Be '/usr/bin/pwsh'
        $command.Arguments | Should -Be '-NoProfile', '-File', 'task.ps1'
    }

    It 'runs a sh with bash' {
        (Get-ScriptCommand -FilePath 'task.sh' -PowerShellPath 'pwsh').Program | Should -Be 'bash'
    }

    It 'refuses other file types' {
        { Get-ScriptCommand -FilePath 'task.exe' -PowerShellPath 'pwsh' } | Should -Throw '*only .ps1, .sh scripts are supported*'
    }
}

Describe 'Invoke-ScriptFile' {
    It 'runs a real script and succeeds on exit code 0' {
        $path = Join-Path $TestDrive 'ok.ps1'
        Set-Content -Path $path -Value 'exit 0'

        { Invoke-ScriptFile -Path $path } | Should -Not -Throw
    }

    It 'throws with the exit code when the script fails' {
        $path = Join-Path $TestDrive 'fail.ps1'
        Set-Content -Path $path -Value 'exit 3'

        { Invoke-ScriptFile -Path $path } | Should -Throw '*exit code 3*'
    }
}

Describe 'Test-PlatformSupported' {
    It 'matches the current platform against the entry platforms' {
        Test-PlatformSupported -Platforms 'windows', 'linux' -CurrentPlatform 'linux' | Should -BeTrue
        Test-PlatformSupported -Platforms 'windows' -CurrentPlatform 'linux' | Should -BeFalse
    }
}
