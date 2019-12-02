function Get-PrimaryIndexString {
    param (
        [string[]] $arrayPrimaryIndex
    )

    $string = ""
    for ($i=0; $i -ne $arrayPrimaryIndex.Count; $i++) {
        $columnInArray = $arrayPrimaryIndex[$i]
        $columnInArrayWithPK = $columnInArray + "_PK"
        $string += "$columnInArray as $columnInArrayWithPK"
        
        if ($i -ne ($arrayPrimaryIndex.Count-1)) {
            $string += " ,`n"
        }
    }

    return $string
}

function Get-ColumnDefinitionString {
    param (
        [string[]] $arrayColumn,
        [string[]] $arrayColumnType,
        [string[]] $arrayPrimaryIndex
    )

    $string = ""
    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $string += "$columnDefinitionBean`n"
        $string = Get-GeneralColumnType $arrayColumnType[$i] $string
        $string = $string -replace [regex]::escape("::columnName::"), $arrayColumn[$i]
        $columnNameWithoutUnSlash = Get-ColumnNameRaw $arrayColumn[$i] "N"
        $string = $string -replace [regex]::escape("::columnNameWithoutUnSlash::"), $columnNameWithoutUnSlash
    }

    for ($j=0; $j -ne $arrayPrimaryIndex.Count; $j++) {
        $string += "$columnDefinitionPIndexBean"
        if ($j -ne ($arrayPrimaryIndex.Count-1)) {
            $string += "`n"
        }

        $string = Get-GeneralColumnType $arrayColumnType[$j] $string
        $primaryColumn = $arrayPrimaryIndex[$j] + "_PK"
        $string = $string -replace [regex]::escape("::columnName::"), $primaryColumn
        $columnNameWithoutUnSlashPK = Get-ColumnNameRaw $arrayPrimaryIndex[$j] "Y"
        $string = $string -replace [regex]::escape("::columnNameWithoutUnSlashPK::"), $columnNameWithoutUnSlashPK
    }

    return $string
}

function Generate-Select {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile,
        [string[]] $arrayColumn,
        [string[]] $arrayColumnType,
        [string[]] $arrayPrimaryIndex
    )
    
    ## Replace ::mainSelect:: < select >
    $allColumnsString = Get-ColumnString $arrayColumn
    $primaryIndexString = Get-PrimaryIndexString $arrayPrimaryIndex
    $mainSelect = "select`n$allColumnsString ,`n$primaryIndexString`nfrom $databaseName.$tableName`nwhere 1=1`n:REPORT_FILTER`n:REPORT_ORDER"
    $replaceMainSelect = Replace-StringInTemplate "::mainSelect::" $mainSelect $targetFile
    $replaceMainSelect | Out-File $targetFile

    ## Replace ::columnDefinition:: < select >
    $columnDefinitionString = Get-ColumnDefinitionString $arrayColumn $arrayColumnType $arrayPrimaryIndex
    $columnDefinition = Replace-StringInTemplate "::columnDefinition::" $columnDefinitionString $targetFile
    $columnDefinition | Out-File $targetFile
}