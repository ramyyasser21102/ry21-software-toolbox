function Test-NeedsElevation {
    param(
        [Parameter(Mandatory)][bool]$RequiresAdmin,
        [Parameter(Mandatory)][bool]$IsElevated
    )

    return $RequiresAdmin -and -not $IsElevated
}

function Test-IsElevated {
    if (-not $IsWindows) {
        return (id -u) -eq '0'
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ElevatedWinget {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $shellPath = (Get-Process -Id $PID).Path
    $command = "winget $($Arguments -join ' ') --accept-source-agreements; exit `$LASTEXITCODE"
    $process = Start-Process -FilePath $shellPath -Verb RunAs -Wait -PassThru -ArgumentList '-NoProfile', '-Command', $command
    return $process.ExitCode
}
