function Invoke-Reg {
    param([Parameter(Mandatory)][string[]]$Arguments)

    if (-not $IsWindows) {
        throw 'Registry tweaks can only be applied on Windows'
    }
    $output = & reg.exe @Arguments 2>&1 | Out-String
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
}

function Test-RegistryKeyExists {
    param([Parameter(Mandatory)][string]$KeyPath)

    return (Invoke-Reg -Arguments 'query', $KeyPath).ExitCode -eq 0
}

function Import-RegFile {
    param([Parameter(Mandatory)][string]$Path)

    $result = Invoke-Reg -Arguments 'import', $Path
    if ($result.ExitCode -ne 0) {
        throw "Importing '$Path' failed: $($result.Output.Trim())"
    }
}

function Export-RegistryKey {
    param(
        [Parameter(Mandatory)][string]$KeyPath,
        [Parameter(Mandatory)][string]$DestinationPath
    )

    $result = Invoke-Reg -Arguments 'export', $KeyPath, $DestinationPath, '/y'
    if ($result.ExitCode -ne 0) {
        throw "Backing up '$KeyPath' failed: $($result.Output.Trim())"
    }
}
