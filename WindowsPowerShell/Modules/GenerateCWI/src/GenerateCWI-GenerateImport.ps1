function Generate-Import {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string[]] $arrayColumn,
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnTypeUpdated
    )

    ## Import mainDeleteSingleRow xml structure
    $import = Replace-StringInTemplate "::mainImport::" $mainImport $targetFile
    $import | Out-File $targetFile

    ## Replace ::deleteAllFromGT:: < import >
    $deleteAllFromGT = "delete from $databaseName.gt_$tableName;"
    $replaceDeleteAllFromGT = Replace-StringInTemplate "::deleteAllFromGT::" $deleteAllFromGT $targetFile
    $replaceDeleteAllFromGT | Out-File $targetFile

    ## Replace ::deleteOrigBasedOnGT:: < import >
    $primaryIndexEqual = Get-PrimaryIndexEqual $arrayPrimaryIndex
    $deleteOrigBasedOnGT = "delete tab1 from`n$databaseName.$tableName tab1,`n$databaseName.gt_$tableName tab2`nwhere $primaryIndexEqual `n;"
    $replaceDeleteOrigBasedOnGT = Replace-StringInTemplate "::deleteOrigBasedOnGT::" $deleteOrigBasedOnGT $targetFile
    $replaceDeleteOrigBasedOnGT | Out-File $targetFile

    ## Replace ::insertOrigBasedOnGT:: < import >
    $allColumnsString = Get-ColumnString $arrayColumn
    $insertOrigBasedOnGT = "insert into $databaseName.$tableName`n(`n$allColumnsString`n)`nselect`n$allColumnsString`nfrom $databaseName.gt_$tableName `n;"
    $replaceInsertOrigBasedOnGT = Replace-StringInTemplate "::insertOrigBasedOnGT::" $insertOrigBasedOnGT $targetFile
    $replaceInsertOrigBasedOnGT | Out-File $targetFile

    ## Replace ::collectStatsOnOrig:: < import >
    $collectStatsOnOrig = "collect statistics on $databaseName.$tableName;"
    $replaceCollectStatsOnOrig = Replace-StringInTemplate "::collectStatsOnOrig::" $collectStatsOnOrig $targetFile
    $replaceCollectStatsOnOrig | Out-File $targetFile
}