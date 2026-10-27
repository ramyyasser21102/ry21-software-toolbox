[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'outdated', 'update')]
    [string]$Command = 'list',

    [Parameter(Position = 1)]
    [string]$Name
)

$ErrorActionPreference = 'Stop'

Get-ChildItem -Path (Join-Path $PSScriptRoot 'src') -Filter '*.ps1' -Recurse -File |
    ForEach-Object { . $_.FullName }

$entriesDirectory = Join-Path $PSScriptRoot 'entries'

switch ($Command) {
    'list' { Invoke-ListCommand -EntriesDirectory $entriesDirectory }
    'outdated' { Invoke-OutdatedCommand -EntriesDirectory $entriesDirectory }
    'update' { Invoke-UpdateCommand -EntriesDirectory $entriesDirectory -Name $Name }
}
