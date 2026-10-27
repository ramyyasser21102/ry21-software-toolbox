function Invoke-Winget {
    param([Parameter(Mandatory)][string[]]$Arguments)

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is not installed or not on the PATH'
    }
    $output = & winget @Arguments --accept-source-agreements 2>&1 | Out-String
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
}

function Get-WingetLatestVersion {
    param([Parameter(Mandatory)][string]$PackageId)

    $result = Invoke-Winget -Arguments 'show', '--id', $PackageId, '--exact', '--source', 'winget'
    if ($result.ExitCode -ne 0) {
        throw "winget could not find package '$PackageId': $($result.Output.Trim())"
    }
    return ConvertFrom-WingetShowOutput -Output $result.Output
}

function Get-WingetInstalledVersion {
    param([Parameter(Mandatory)][string]$PackageId)

    # winget exits non-zero when the package is simply not installed, so only the output decides.
    $result = Invoke-Winget -Arguments 'list', '--id', $PackageId, '--exact'
    return ConvertFrom-WingetListOutput -Output $result.Output -PackageId $PackageId
}

function Get-WingetInstallArguments {
    param([Parameter(Mandatory)][string]$PackageId)

    'install', '--id', $PackageId, '--exact', '--source', 'winget', '--silent', '--accept-package-agreements'
}
