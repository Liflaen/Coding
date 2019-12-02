function Get-PrimaryIndexEqual {
    param (
        [string[]] $arrayPrimaryIndex
    )

    $string = ""
    for ($i=0; $i -ne $arrayPrimaryIndex.Count; $i++) {
        $primaryIndex = $arrayPrimaryIndex[$i]
        $string += "tab1.$primaryIndex = tab2.$primaryIndex"

        if ($i -ne ($arrayPrimaryIndex.Count-1)) {
            $string += " and`n"
        }
    }

    return $string
}

function Get-PrimaryCondition {
    param (
        [string[]] $arrayPrimaryIndex,
        [string[]] $arrayColumnType,
        [string[]] $arrayColumn,
        [string] $primaryKeySuffix
    )

    $string = ""
    for ($i=0; $i -ne $arrayPrimaryIndex.Count; $i++) {
        $primaryIndex = $arrayPrimaryIndex[$i]
        for ($j=0; $j -ne $arrayColumn.Count; $j++) {
            if ($arrayColumn[$j] -eq $primaryIndex) {
                $columnType = $arrayColumnType[$j]
            }
        }

        if ($primaryKeySuffix -eq "Y") {
            $string += "$primaryIndex = :PARAM_$columnType" + "_$primaryIndex" + "_PK"
        }
        else {
            $string += "$primaryIndex = :PARAM_$columnType" + "_$primaryIndex"
        }

        if ($i -ne ($arrayPrimaryIndex.Count-1)) {
            $string += " and`n"
        }
    }

    return $string
}

function Get-ValidationNotNullBean {
    param (
        [string[]] $arraryNotNullColumn
    )
    
    $string = ""
    for ($i=0; $i -ne $arraryNotNullColumn.Count; $i++) {
        $notNullColumn = $arraryNotNullColumn[$i]
        
        if (($notNullColumn -ne "Updated_When") -and ($notNullColumn -ne "Updated_By") -and ($notNullColumn -ne "Created_By") -and ($notNullColumn -ne "Created_When")) {
            $string += $columnNotNulValidation

            if ($i -ne ($arraryNotNullColumn.Count-1)) {
                $string += "`n"
            }

            $string = $string -replace [regex]::escape("::columnName::"), $notNullColumn
        }
    }
    
    return $string
}

function Get-ColumnValueBean {
    param (
        [string[]] $arrayColumn
    )
    
    $string = ""
    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $columnName = $arrayColumn[$i]
        if (($columnName -ne "Updated_When") -and ($columnName -ne "Updated_By") -and ($columnName -ne "Created_By") -and ($columnName -ne "Created_When")) {
            $string += $columnValueBean

            if ($i -ne ($arrayColumn.Count-1)) {
                $string += "`n"
            }

            $string = $string -replace [regex]::escape("::columnName::"), $columnName
        }
    }

    return $string
}

function Comment-AllUnusedXML {
    param (
        [string] $targetFile
    )
    
    $regex = "^(::\w+::)"
    $gcFile = Get-Content $targetFile
    $r = $gcFile | Select-String $regex
    $r = $r | Select-Object -Unique
    for ($i=0; $i -ne $r.Count; $i++) {
        $element = $r[$i]
        $string = Replace-StringInTemplate $element "<!-- $element -->" $targetFile
        $string | Out-File $targetFile
    }
}