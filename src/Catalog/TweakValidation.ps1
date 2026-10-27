function Get-AffectedKeyErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $badKeys = @($Manifest.affectedKeys) | Where-Object { $_ -and $_ -notmatch '^(HKCU|HKLM)\\.+' }
    return @($badKeys | ForEach-Object { "affectedKeys entry '$_' must start with HKCU\ or HKLM\" })
}

function Get-TweakErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    return Get-AffectedKeyErrors -Manifest $Manifest
}

function Get-ScriptErrors {
    param([Parameter(Mandatory)][psobject]$Manifest)

    $errors = @(Get-AffectedKeyErrors -Manifest $Manifest)
    foreach ($field in 'applyFile', 'undoFile') {
        $extension = [IO.Path]::GetExtension([string]$Manifest.$field)
        if ($extension -notin (Get-ScriptExtensions)) {
            $errors += "$field '$($Manifest.$field)' must end in one of: $((Get-ScriptExtensions) -join ', ')"
        }
    }
    return $errors
}
