function Get-PrimaryNotEqualColumn {
    param (
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnType,
        [string[]] $arrayColumn
    )

    $string = ""
    for ($i=0; $i -ne $arrayPrimaryIndex.Count; $i++) {
        $primaryIndex = $arrayPrimaryIndex[$i]
        for ($j=0; $j -ne $arrayColumn.Count; $j++) {
            if ($arrayColumn[$j] -eq $primaryIndex) {
                $columnType = $arrayColumnType[$j]
            }
        }

        $string += " :PARAM_$columnType" + "_$primaryIndex <> :PARAM_$columnType" + "_$primaryIndex" + "_PK"

        if ($i -ne ($arrayPrimaryIndex.Count-1)) {
            $string += " or`n"
        }
    }

    return $string
}

function Generate-Update {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string[]] $arrayColumn,
        [string[]] $arrayPrimaryIndex,
        [string[]] $arraryNotNullColumn,
        [string[]] $arrayColumnTypeUpdated
    )

    ## Import mainUpdate xml structure
    $update = Replace-StringInTemplate "::mainUpdate::" $mainUpdate $targetFile
    $update | Out-File $targetFile

    ## Replace ::columnValueBean:: < update >
    $allColumnValueBean = Get-ColumnValueBean $arrayColumn
    $replaceColumnValueBean = Replace-StringInTemplate "::columnValueBean::" $allColumnValueBean $targetFile
    $replaceColumnValueBean | Out-File $targetFile

    ## Replace ::validationNotNull:: < update > Commented DUE to not validating columns!
    <# $allNotNullColumns = Get-ValidationNotNullBean $arraryNotNullColumn
    $replaceValidationNotNull = Replace-StringInTemplate "::validationNotNull::" $allNotNullColumns $targetFile
    $replaceValidationNotNull | Out-File $targetFile #>
    ## Special replace for only primary indexes
    $allPrimaryColumns = Get-ValidationNotNullBean $arrayPrimaryIndex
    $replaceValidationNotNull = Replace-StringInTemplate "::validationNotNull::" $allPrimaryColumns $targetFile
    $replaceValidationNotNull | Out-File $targetFile

    ## Replace ::columnNamePrimaryFirst:: < update >
    $replacePrimaryFirst = Replace-StringInTemplate "::columnNamePrimaryFirst::" $arrayPrimaryIndex[0] $targetFile
    $replacePrimaryFirst | Out-File $targetFile

    ## Replace ::selectForDuplicityCheckUpdate:: < update >
    $primaryIndexWithParamsN = Get-PrimaryCondition $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn "N"
    $primaryIndexNotEqual = Get-PrimaryNotEqualColumn $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn
    $primaryConditionForValidateUpdate = "select * from $databaseName.$tableName`nwhere $primaryIndexWithParamsN and`n(`n$primaryIndexNotEqual`n)`n;"
    $replaceselectForDuplicityCheckUpdate = Replace-StringInTemplate "::selectForDuplicityCheckUpdate::" $primaryConditionForValidateUpdate $targetFile
    $replaceselectForDuplicityCheckUpdate | Out-File $targetFile

    ## Replace ::updateOrigTableWithParams:: < update >
    $primaryIndexWithParamsY = Get-PrimaryCondition $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn "Y"
    $combiWithParams = Get-ColumnsCombiWithParams $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn "WithComma"
    $combiWithParamsString = "update $databaseName.$tableName`nset`n$combiWithParams`nwhere`n$primaryIndexWithParamsY `n;"
    $replaceCombiWithParamsString = Replace-StringInTemplate "::updateOrigTableWithParams::" $combiWithParamsString $targetFile
    $replaceCombiWithParamsString | Out-File $targetFile

    ## Replace ::selectForNoChangeCheck:: < update > 
    # To do
}