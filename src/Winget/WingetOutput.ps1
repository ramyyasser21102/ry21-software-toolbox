function ConvertFrom-WingetShowOutput {
    param([Parameter(Mandatory)][string]$Output)

    if ($Output -notmatch '(?m)^\s*Version:\s*(\S+)') {
        throw 'winget did not report a version for the package'
    }
    return $Matches[1]
}

function ConvertFrom-WingetListOutput {
    param(
        [Parameter(Mandatory)][string]$Output,
        [Parameter(Mandatory)][string]$PackageId
    )

    $escapedId = [regex]::Escape($PackageId)
    if ($Output -notmatch "(?m)\s$escapedId\s+(\S+)") {
        return $null
    }
    return $Matches[1]
}
