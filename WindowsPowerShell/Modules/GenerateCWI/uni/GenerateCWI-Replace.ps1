function Replace-StringInTemplate {
    param (
        [string] $replaceWhat,
        [string] $replaceWith,
        [string] $targetFile
    )
    $gcTargetFile = Get-Content $targetFile

    $result = $gcTargetFile -replace [regex]::escape("$replaceWhat"), $replaceWith
    
    return $result
}