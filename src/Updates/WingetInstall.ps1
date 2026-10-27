function Install-WingetPackage {
    param(
        [Parameter(Mandatory)][string]$PackageId,
        [Parameter(Mandatory)][bool]$RequiresAdmin
    )

    $arguments = Get-WingetInstallArguments -PackageId $PackageId
    if (Test-NeedsElevation -RequiresAdmin $RequiresAdmin -IsElevated (Test-IsElevated)) {
        $exitCode = Invoke-ElevatedWinget -Arguments $arguments
    }
    else {
        $exitCode = (Invoke-Winget -Arguments $arguments).ExitCode
    }
    if ($exitCode -ne 0) {
        throw "winget failed to install '$PackageId' (exit code $exitCode)"
    }
}
