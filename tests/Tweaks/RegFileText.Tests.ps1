BeforeAll {
    . "$PSScriptRoot/../../src/Tweaks/RegFileText.ps1"

    $regText = "Windows Registry Editor Version 5.00`r`n`r`n[HKEY_CURRENT_USER\Software\Example]`r`n`"Flag`"=dword:00000001`r`n"
}

Describe 'Get-RegFileChangeLines' {
    It 'drops the header and blank lines' {
        Get-RegFileChangeLines -RegFileText $regText | Should -Be '[HKEY_CURRENT_USER\Software\Example]', '"Flag"=dword:00000001'
    }
}

Describe 'Get-RegFileKeys' {
    It 'lists keys in short form, including keys marked for deletion' {
        $text = "Windows Registry Editor Version 5.00`n[HKEY_CURRENT_USER\A]`n[-HKEY_LOCAL_MACHINE\B\C]`n"

        Get-RegFileKeys -RegFileText $text | Should -Be 'HKCU\A', 'HKLM\B\C'
    }
}

Describe 'Get-UncoveredKeys' {
    It 'accepts keys equal to or below an affected key' {
        $text = "[HKEY_CURRENT_USER\Software\Example]`n[HKEY_CURRENT_USER\Software\Example\Sub]`n"

        Get-UncoveredKeys -RegFileText $text -AffectedKeys 'HKCU\Software\Example' | Should -BeNullOrEmpty
    }

    It 'reports keys outside the affected keys' {
        $text = "[HKEY_CURRENT_USER\Software\Example]`n[HKEY_CURRENT_USER\Software\Other]`n"

        Get-UncoveredKeys -RegFileText $text -AffectedKeys 'HKCU\Software\Example' | Should -Be 'HKCU\Software\Other'
    }

    It 'does not treat a key that merely shares a prefix as covered' {
        Get-UncoveredKeys -RegFileText '[HKEY_CURRENT_USER\Software\ExampleExtra]' -AffectedKeys 'HKCU\Software\Example' | Should -Be 'HKCU\Software\ExampleExtra'
    }
}
