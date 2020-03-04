function Update-LogTableToD {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string] $primaryIndexWithParamsY
    )

    $string = "update $databaseName.Log_$tableName`nset Row_Status = 'D'`nwhere $primaryIndexWithParamsY `n;"
    $result = Replace-StringInTemplate "::updateLogTableToD::" $string $targetFile
    $result | Out-File $targetFile
}

function Insert-IntoLogTableWithParamsMultiLog {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $allColumnsString,
        [string] $paramColumnsString,
        [string] $logColumnsStringGeneral,
        [string] $logColumnsStringValues,
        [string[]] $arrayColumn,
        [string[]] $arrayColumnTypeUpdated
    )

    ## Replace ::insertIntoLogTableWithParams:: < insert > 
    $insertIntoLogTableWithParams = "insert into $databaseName.Log_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nvalues`n(`n$paramColumnsString ,`n$logColumnsStringValues`n)`n;"
    $replaceInsertIntoLogTableWithParams = Replace-StringInTemplate "::insertIntoLogTableWithParams::" $insertIntoLogTableWithParams $targetFile
    $replaceInsertIntoLogTableWithParams | Out-File $targetFile
    
    ## Replace ::updateIntoLogTableWithParams:: < update > 
    $updateIntoLogTableWithParams = "insert into $databaseName.Log_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nvalues`n(`n$paramColumnsString ,`n$logColumnsStringValues`n)`n;"
    $replaceUpdateIntoLogTableWithParams = Replace-StringInTemplate "::updateIntoLogTableWithParams::" $updateIntoLogTableWithParams $targetFile
    $replaceUpdateIntoLogTableWithParams | Out-File $targetFile

    ## Replace ::insertLogBasedOnGT:: < import >
    $insertLogBasedOnGT = "insert into $databaseName.Log_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nselect`n$allColumnsString ,`n$logColumnsStringGeneral`nfrom $databaseName.gt_$tableName `n;"
    $replaceInsertLogBasedOnGT = Replace-StringInTemplate "::insertLogBasedOnGT::" $insertLogBasedOnGT $targetFile
    $replaceInsertLogBasedOnGT | Out-File $targetFile

    ## Replace ::insertIntoGTWithParams:: < import >
    $insertIntoGT = "insert into $databaseName.gt_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nvalues`n(`n$paramColumnsString ,`n$logColumnsStringValues`n)`n;"
    $replaceInsertIntoGT = Replace-StringInTemplate "::insertIntoGTWithParams::" $insertIntoGT $targetFile
    $replaceInsertIntoGT | Out-File $targetFile
}

function Insert-IntoLogTableWithParamsSingleLog {
    param (
        [string] $databaseName,
        [string] $allColumnsString,
        [string] $paramColumnsString,
        [string[]] $arrayColumn,
        [string[]] $arrayColumnTypeUpdated,
        [string[]] $arraryNotNullColumn
    )
    
    $logColumnsStringGeneral = Get-LogColumnString "Column" "Single"
    $logColumnsStringValues = Get-LogColumnString "Value" "Single"
    $combiWithParams = Get-ColumnsCombiWithParams $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn "WithJoin"
    $combiWithParamsGeneral = Get-ColumnsCombiWithParams $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn "WithJoinGen"

    ## Replace ::insertIntoLogTableWithParams:: < insert >
    $insertIntoLogTableWithParams = "insert into $databaseName.$singleLogName`n(`nAction_Desc ,`nTable_Name ,`nQuery_Text ,`n$logColumnsStringGeneral`n)`nvalues`n(`n'Insert' ,`n'::tableName::' ,`n$combiWithParams ,`n$logColumnsStringValues`n)`n;"
    $replaceInsertIntoLogTableWithParams = Replace-StringInTemplate "::insertIntoLogTableWithParams::" $insertIntoLogTableWithParams $targetFile
    $replaceInsertIntoLogTableWithParams | Out-File $targetFile

    ## Replace ::updateIntoLogTableWithParams:: < update >
    $updateIntoLogTableWithParams = "insert into $databaseName.$singleLogName`n(`nAction_Desc ,`nTable_Name ,`nQuery_Text ,`n$logColumnsStringGeneral`n)`nvalues`n(`n'Update' ,`n'::tableName::' ,`n$combiWithParams ,`n$logColumnsStringValues`n)`n;"
    $replaceUpdateIntoLogTableWithParams = Replace-StringInTemplate "::updateIntoLogTableWithParams::" $updateIntoLogTableWithParams $targetFile
    $replaceUpdateIntoLogTableWithParams | Out-File $targetFile

    ## Replace ::insertLogBasedOnGT:: < import >
    $insertLogBasedOnGT = "insert into $databaseName.$singleLogName`n(`nAction_Desc ,`nTable_Name ,`nQuery_Text ,`n$logColumnsStringGeneral`n)`nselect`n'Import' ,`n'::tableName::' ,`n$combiWithParamsGeneral ,`n$logColumnsStringGeneral`nfrom $databaseName.gt_$tableName `n;"
    $replaceInsertLogBasedOnGT = Replace-StringInTemplate "::insertLogBasedOnGT::" $insertLogBasedOnGT $targetFile
    $replaceInsertLogBasedOnGT | Out-File $targetFile

    ## Replace ::insertIntoGTWithParams:: < import >
    $insertIntoGT = "insert into $databaseName.gt_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nvalues`n(`n$paramColumnsString ,`n$logColumnsStringValues`n)`n;"
    $replaceInsertIntoGT = Replace-StringInTemplate "::insertIntoGTWithParams::" $insertIntoGT $targetFile
    $replaceInsertIntoGT | Out-File $targetFile
}

function Replace-AllMultiXMLStructure {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [bool] $singleLog,
        [bool] $multiLog,
        [string[]] $arrayColumn,
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnTypeUpdated,
        [string[]] $arraryNotNullColumn
    )
    $allColumnsString = Get-ColumnString $arrayColumn
    $paramColumnsString = Get-ParamColumnsString $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn

    if ($multiLog) {
        $logColumnsStringGeneral = Get-LogColumnString "Column" "Multi"
        $logColumnsStringValues = Get-LogColumnString "Value" "Multi"

        ## Replace ::insertIntoLogTableWithParams::
        Insert-IntoLogTableWithParamsMultiLog $tableName $databaseName $allColumnsString $paramColumnsString $logColumnsStringGeneral $logColumnsStringValues $arrayColumn $arrayColumnTypeUpdated
        
        ## Replace ::updateLogTableToD::
        $primaryIndexWithParamsY = Get-PrimaryCondition $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn "Y"
        Update-LogTableToD $tableName $databaseName $targetFile $primaryIndexWithParamsY

        ## Replace ::updateLogBasedOnGT::
        $primaryIndexEqual = Get-PrimaryIndexEqual $arrayPrimaryIndex
        $updateLogBasedOnGT = "update tab1 from`n$databaseName.Log_$tableName tab1,`n$databaseName.gt_$tableName tab2`nset Row_Status = 'D'`nwhere $primaryIndexEqual `n;"
        $replaceUpdateLogBasedOnGT = Replace-StringInTemplate "::updateLogBasedOnGT::" $updateLogBasedOnGT $targetFile
        $replaceUpdateLogBasedOnGT | Out-File $targetFile

        ## Replace ::insertIntoGTWithParams:: < import >
        $insertIntoGT = "insert into $databaseName.gt_$tableName`n(`n$allColumnsString ,`n$logColumnsStringGeneral`n)`nvalues`n(`n$paramColumnsString ,`n$logColumnsStringValues`n)`n;"
        $replaceInsertIntoGT = Replace-StringInTemplate "::insertIntoGTWithParams::" $insertIntoGT $targetFile
        $replaceInsertIntoGT | Out-File $targetFile

        ## Replace ::updateAllInLog:: < delete all >
        $updateAllInLog = "update $databaseName.Log_$tableName`nset Row_Status = 'D'`nwhere Row_Status = 'A';"
        $replaceUpdateAllInLog = Replace-StringInTemplate "::updateAllInLog::" $updateAllInLog $targetFile
        $replaceUpdateAllInLog | Out-File $targetFile
    }

    if ($singleLog) {
        ## Replace ::insertIntoLogTableWithParams:: 
        Insert-IntoLogTableWithParamsSingleLog $databaseName $allColumnsString $paramColumnsString $arrayColumn $arrayColumnTypeUpdated $arraryNotNullColumn
    }

    ## Replace ::updateAllInLog::
    $replaceUpdateAllInLog = Replace-StringInTemplate "::updateAllInLog::" "" $targetFile
    $replaceUpdateAllInLog | Out-File $targetFile

    ## Replace ::insertIntoLogTableWithParams::
    $replaceInsertIntoLogTableWithParams = Replace-StringInTemplate "::insertIntoLogTableWithParams::" "" $targetFile
    $replaceInsertIntoLogTableWithParams | Out-File $targetFile

    ## Replace ::insertLogBasedOnGT::
    $replaceInsertLogBasedOnGT = Replace-StringInTemplate "::insertLogBasedOnGT::" "" $targetFile
    $replaceInsertLogBasedOnGT | Out-File $targetFile

    ## Replace ::updateLogTableToD::
    $replaceUpdateLogTableToD = Replace-StringInTemplate "::updateLogTableToD::" "" $targetFile
    $replaceUpdateLogTableToD | Out-File $targetFile

    ## Replace ::updateLogBasedOnGT::
    $replaceUpdateLogBasedOnGT = Replace-StringInTemplate "::updateLogBasedOnGT::" "" $targetFile
    $replaceUpdateLogBasedOnGT | Out-File $targetFile

    ## Replace ::::tableName:::: 
    $replaceTableName = Replace-StringInTemplate "::tableName::" $tableName $targetFile
    $replaceTableName | Out-File $targetFile

    ## Comment all unused xml structure ::xxx:: < main >
    Comment-AllUnusedXML $targetFile

    ## Convert file to UTF8
    $resolvedTargetPath = Resolve-Path $targetFile
    $gcTargetFile = Get-Content $resolvedTargetPath
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($resolvedTargetPath, $gcTargetFile, $Utf8NoBomEncoding)
}