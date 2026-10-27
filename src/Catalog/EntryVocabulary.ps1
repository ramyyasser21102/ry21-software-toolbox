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

function Get-VersionSourceTypes {
    'github-releases', 'winget'
}

function Get-InstallDetectionTypes {
    'file-version', 'winget-list'
}

function Get-DeliveryTypes {
    'portable-zip', 'winget'
}

function Get-ChecksumTypes {
    'github-asset-digest'
}

function Get-RequiredManifestFields {
    param([Parameter(Mandatory)][string]$Kind)

    $fieldsEveryKindNeeds = 'name', 'kind', 'category', 'platforms', 'description'
    switch ($Kind) {
        'software' { return $fieldsEveryKindNeeds + 'licenseType', 'upstreamUrl', 'versionSource', 'installDetection', 'delivery' }
        'registry-tweak' { return $fieldsEveryKindNeeds + 'applyFile', 'undoFile', 'affectedKeys' }
        default { return $fieldsEveryKindNeeds }
    }
}
