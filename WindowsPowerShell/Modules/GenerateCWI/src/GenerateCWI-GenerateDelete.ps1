function Generate-Delete {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnTypeUpdated,
        [string[]] $arrayColumn
    )

    ## Import mainDeleteSingleRow xml structure
    $single = Replace-StringInTemplate "::deleteSingleRow::" $deleteSingle $targetFile
    $single | Out-File $targetFile

    ## Import mainDeleteMultiRow xml structure
    $multi = Replace-StringInTemplate "::deleteMultiRow::" $deleteMulti $targetFile
    $multi | Out-File $targetFile

    ## Replace ::deleteOrigTable:: < delete >
    $primaryIndexWithParamsY = Get-PrimaryCondition $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn "Y"
    $deleteFromOrig = "delete from $databaseName.$tableName`nwhere $primaryIndexWithParamsY `n;"
    $replaceDeleteFromOrig = Replace-StringInTemplate "::deleteOrigTable::" $deleteFromOrig $targetFile
    $replaceDeleteFromOrig | Out-File $targetFile
}