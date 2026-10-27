[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list')]
    [string]$Command = 'list'
)

$ErrorActionPreference = 'Stop'

Get-ChildItem -Path (Join-Path $PSScriptRoot 'src') -Filter '*.ps1' -Recurse -File |
    ForEach-Object { . $_.FullName }

$entriesDirectory = Join-Path $PSScriptRoot 'entries'

switch ($Command) {
    'list' { Invoke-ListCommand -EntriesDirectory $entriesDirectory }
}
