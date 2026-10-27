function Get-RegFileChangeLines {
    param([Parameter(Mandatory)][string]$RegFileText)

    $headerLine = 'Windows Registry Editor Version 5.00'
    $RegFileText -split '\r?\n' |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_.Trim() -ne $headerLine }
}

function ConvertTo-ShortKeyPath {
    param([Parameter(Mandatory)][string]$KeyPath)

    $KeyPath -replace '^HKEY_CURRENT_USER', 'HKCU' -replace '^HKEY_LOCAL_MACHINE', 'HKLM'
}

function Get-RegFileKeys {
    param([Parameter(Mandatory)][string]$RegFileText)

    Get-RegFileChangeLines -RegFileText $RegFileText |
        Where-Object { $_ -match '^\[-?(?<key>[^\]]+)\]' } |
        ForEach-Object { ConvertTo-ShortKeyPath -KeyPath $Matches.key }
}

function Get-UncoveredKeys {
    param(
        [Parameter(Mandatory)][string]$RegFileText,
        [Parameter(Mandatory)][string[]]$AffectedKeys
    )

    Get-RegFileKeys -RegFileText $RegFileText | Where-Object {
        $key = $_
        -not ($AffectedKeys | Where-Object { $key -eq $_ -or $key.StartsWith("$_\") })
    }
}
