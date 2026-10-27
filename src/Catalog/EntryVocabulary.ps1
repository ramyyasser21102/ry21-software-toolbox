function Get-EntryCategories {
    'monitoring', 'stress-test', 'benchmark', 'media', 'drivers', 'tweaks'
}

function Get-EntryKinds {
    'software', 'registry-tweak', 'script'
}

function Get-EntryPlatforms {
    'windows', 'linux'
}

function Get-LicenseTypes {
    'open-source', 'freeware', 'free-personal-use'
}

function Get-RequiredManifestFields {
    param([Parameter(Mandatory)][string]$Kind)

    $fieldsEveryKindNeeds = 'name', 'kind', 'category', 'platforms', 'description'
    if ($Kind -eq 'software') {
        return $fieldsEveryKindNeeds + 'licenseType', 'upstreamUrl'
    }
    return $fieldsEveryKindNeeds
}
