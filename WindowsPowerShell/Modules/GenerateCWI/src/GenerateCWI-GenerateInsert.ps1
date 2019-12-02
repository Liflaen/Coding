function Generate-Insert {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string[]] $arrayColumn,        
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnTypeUpdated,
        [string[]] $arraryNotNullColumn
    )

    ## Import mainInsert xml structure
    $insert = Replace-StringInTemplate "::mainInsert::" $mainInsert $targetFile
    $insert | Out-File $targetFile

    $allColumnsString = Get-ColumnString $arrayColumn
    $paramColumnsString = Get-ParamColumnsString $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn

    ## Replace ::insertIntoOrigTableWithParams:: < insert > 
    $origTableString = "insert into $databaseName.$tableName`n(`n$allColumnsString`n)`nvalues`n(`n$paramColumnsString`n)`n;"
    $replaceOrigTableString = Replace-StringInTemplate "::insertIntoOrigTableWithParams::" $origTableString $targetFile
    $replaceOrigTableString | Out-File $targetFile

    ## Replace ::columnValueBean:: < insert >
    $allColumnValueBean = Get-ColumnValueBean $arrayColumn
    $replaceColumnValueBean = Replace-StringInTemplate "::columnValueBean::" $allColumnValueBean $targetFile
    $replaceColumnValueBean | Out-File $targetFile

    ## Replace ::validationNotNull:: < insert > Commented DUE to not validating columns!
    <# $allNotNullColumns = Get-ValidationNotNullBean $arraryNotNullColumn
    $replaceValidationNotNull = Replace-StringInTemplate "::validationNotNull::" $allNotNullColumns $targetFile
    $replaceValidationNotNull | Out-File $targetFile #>
    ## Special replace for only primary indexes
    $allPrimaryColumns = Get-ValidationNotNullBean $arrayPrimaryIndex
    $replaceValidationNotNull = Replace-StringInTemplate "::validationNotNull::" $allPrimaryColumns $targetFile
    $replaceValidationNotNull | Out-File $targetFile

    ## Replace ::columnNamePrimaryFirst:: < insert >
    $replacePrimaryFirst = Replace-StringInTemplate "::columnNamePrimaryFirst::" $arrayPrimaryIndex[0] $targetFile
    $replacePrimaryFirst | Out-File $targetFile

    ## Replace ::selectForDuplicityCheck:: < insert > 
    $primaryIndexWithParamsN = Get-PrimaryCondition $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn "N"
    $primaryConditionForValidate = "select * from $databaseName.$tableName`nwhere $primaryIndexWithParamsN `n;"
    $replaceSelectForDuplicityCheck = Replace-StringInTemplate "::selectForDuplicityCheck::" $primaryConditionForValidate $targetFile
    $replaceSelectForDuplicityCheck | Out-File $targetFile
}