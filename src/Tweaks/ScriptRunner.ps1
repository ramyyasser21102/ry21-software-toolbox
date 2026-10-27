function Get-ScriptCommand {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string]$PowerShellPath
    )

    switch ([IO.Path]::GetExtension($FilePath)) {
        '.ps1' { return [pscustomobject]@{ Program = $PowerShellPath; Arguments = @('-NoProfile', '-File', $FilePath) } }
        '.sh' { return [pscustomobject]@{ Program = 'bash'; Arguments = @($FilePath) } }
        default { throw "Cannot run '$FilePath': only $((Get-ScriptExtensions) -join ', ') scripts are supported" }
    }
}

function Invoke-ScriptFile {
    param([Parameter(Mandatory)][string]$Path)

    $command = Get-ScriptCommand -FilePath $Path -PowerShellPath (Get-Process -Id $PID).Path
    & $command.Program @($command.Arguments)
    if ($LASTEXITCODE -ne 0) {
        throw "Script '$(Split-Path $Path -Leaf)' failed with exit code $LASTEXITCODE"
    }
}

function Show-ScriptPreview {
    param(
        [Parameter(Mandatory)][psobject]$Entry,
        [Parameter(Mandatory)][string]$ScriptPath
    )

    Write-Host "'$($Entry.name)': $($Entry.description)"
    Write-Host "This will run $(Split-Path $ScriptPath -Leaf):"
    Get-Content -LiteralPath $ScriptPath | ForEach-Object { Write-Host "  $_" }
}
