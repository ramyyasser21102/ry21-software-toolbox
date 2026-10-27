[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'outdated', 'update', 'apply', 'undo')]
    [string]$Command = 'list',

    [Parameter(Position = 1)]
    [string]$Name,

    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

Get-ChildItem -Path (Join-Path $PSScriptRoot 'src') -Filter '*.ps1' -Recurse -File |
    ForEach-Object { . $_.FullName }

$entriesDirectory = Join-Path $PSScriptRoot 'entries'

switch ($Command) {
    'list' { Invoke-ListCommand -EntriesDirectory $entriesDirectory }
    'outdated' { Invoke-OutdatedCommand -EntriesDirectory $entriesDirectory }
    'update' { Invoke-UpdateCommand -EntriesDirectory $entriesDirectory -Name $Name }
    'apply' { Invoke-ApplyCommand -EntriesDirectory $entriesDirectory -Name $Name -SkipConfirmation:$Yes }
    'undo' { Invoke-UndoCommand -EntriesDirectory $entriesDirectory -Name $Name -SkipConfirmation:$Yes }
}
