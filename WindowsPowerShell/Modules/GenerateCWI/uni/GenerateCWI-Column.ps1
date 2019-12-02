function Get-ColumnString {
    param (
        [string[]] $arrayColumn
    )
    
    $string = ""
    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $columnInArray = $arrayColumn[$i]
        $string += "$columnInArray"
        if ($i -ne ($arrayColumn.Count-1)) {
            $string += " ,`n"
        }
    }

    return $string
}

function Get-GeneralColumnType {
    param (
        [string] $columnType,
        [string] $string
    )
    
    if (($columnType -eq "varchar") -or ($columnType -eq "char")) {
        $string = $string -replace [regex]::escape("::columnType::"), "StringColumn"
    }
    elseif (($columnType -eq "smallint") -or ($columnType -eq "integer") -or ($columnType -eq "byteint")) {
        $string = $string -replace [regex]::escape("::columnType::"), "IntegerColumn"
    }
    elseif ($columnType -eq "decimal") {
        $string = $string -replace [regex]::escape("::columnType::"), "DecimalColumn"
    }
    elseif ($columnType -eq "date") {
        $string = $string -replace [regex]::escape("::columnType::"), "DateColumn"
    }
    elseif ($columnType -eq "timestamp") {
        $string = $string -replace [regex]::escape("::columnType::"), "PreciseDateTimeColumn"
    }
    else {
        $string = $string -replace [regex]::escape("::columnType::"), "UnKnown"
    }

    return $string
}

function Get-ColumnNameRaw {
    param (
        [string] $nameOfColumn,
        [string] $pkFlag
    )
    
    $countOfUnSlashes = $nameOfColumn.Split('_').Count
    $res = ""
    for ($i=0; $i -ne $countOfUnSlashes; $i++) {
        $part = $nameOfColumn.Split('_')[$i]
        if ($i -ne $countOfUnSlashes-1) {
            $res = $res + "$part "
        }
        else {
            if ($pkFlag -eq "Y") {
                $res = $res + "$part - PK"
            }
            else {
                $res = $res + "$part"
            }
        }
    }

    return $res    
}

function Get-ParamColumnsString {
    param (
        [string[]] $arrayColumn,
        [string[]] $arrayColumnType,
        [string[]] $arraryNotNullColumn
    )
    
    $string = ""
    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $columnName = $arrayColumn[$i]
        $columnType = $arrayColumnType[$i]
        $columnNotNull = "Unknown"
        for ($j=0; $j -ne $arraryNotNullColumn.Count; $j++) {
            if ($arraryNotNullColumn[$j] -eq $columnName) {
                $columnNotNull = $columnName
            }
        }

        if (($columnName -ne "Updated_When") -and ($columnName -ne "Updated_By") -and ($columnName -ne "Created_By") -and ($columnName -ne "Created_When")) {
            if ($columnNotNull -ne $columnName) {
                $string += ":PARAM_$columnType" + "_$columnName"
            }
            else {
                if ($columnType -eq "decimal" -or $columnType -eq "integer") {
                    $string += "coalesce( :PARAM_$columnType" + "_$columnName , 0)"
                }
                elseif ($columnType -eq "date") {
                    $string += "coalesce( cast( :PARAM_$columnType" + "_$columnName as date) , date '2999-12-31')"
                }
                else {
                    $string += "coalesce( :PARAM_$columnType" + "_$columnName , '')"
                }
            }
        }
        else {
            $string += "$columnType"
        }

        if ($i -ne ($arrayColumn.Count-1)) {
            $string += " ,`n"
        }
    }
    
    return $string
}

function Get-LogColumnString {
    param (
        [string] $isItValue,
        [string] $logType
    )
    if ($isItValue -eq "Column") {
        if ($logType -eq "Multi") {
            $string = "Row_Status ,`nUpdated_by_User ,`nUpdated_When ,`nUpdated_by_Session"
        }
        else {
            $string = "Updated_by_User ,`nUpdated_When_CWI"
        }
    }
    else {
        if ($logType -eq "Multi") {
            $string = "'A' ,`n:PARAM_CurrentUser ,`nCURRENT_TIMESTAMP(0) ,`n1"
        }
        else {
            $string = ":PARAM_CurrentUser ,`nCURRENT_TIMESTAMP(0)"
        }
    }

    return $string
}

function Get-ColumnsCombiWithParams {
    param (
        [string[]] $arrayColumn,
        [string[]] $arrayColumnType,
        [string[]] $arraryNotNullColumn,
        [string] $lineEnd
    )

    $string = ""
    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $columnName = $arrayColumn[$i]
        $columnType = $arrayColumnType[$i]
        $columnNotNull = "Unknown"
        for ($j=0; $j -ne $arraryNotNullColumn.Count; $j++) {
            if ($arraryNotNullColumn[$j] -eq $columnName) {
                $columnNotNull = $columnName
            }
        }

        if (($columnName -ne "Updated_When") -and ($columnName -ne "Updated_By") -and ($columnName -ne "Created_By") -and ($columnName -ne "Created_When")) {
            if ($lineEnd -eq "WithJoin") {
                if ($columnType -eq "decimal" -or $columnType -eq "integer") {
                    $string += "'$columnName = ' || coalesce( :PARAM_$columnType" + "_$columnName , 0)"
                }
                elseif ($columnType -eq "date") {
                    $string += "'$columnName = ' || coalesce( cast( :PARAM_$columnType" + "_$columnName as date) , date '2999-12-31')"
                }
                else {
                    $string += "'$columnName = ' || coalesce( :PARAM_$columnType" + "_$columnName , '')"
                }
            }
            elseif ($lineEnd -eq "WithJoinGen") {
                if ($columnNotNull -ne $columnName) {
                    $string += "'$columnName = ' || $columnName"
                }
                else {
                    if ($columnType -eq "decimal" -or $columnType -eq "integer") {
                        $string += "'$columnName = ' || coalesce( $columnName , 0)"
                    }
                    elseif ($columnType -eq "date") {
                        $string += "'$columnName = ' || coalesce( cast( $columnName as date) , date '2999-12-31')"
                    }
                    else {
                        $string += "'$columnName = ' || coalesce( $columnName , '')"
                    }
                }
                
            }
            else {
                if ($columnNotNull -ne $columnName) {
                    $string += "$columnName = :PARAM_$columnType" + "_$columnName"
                }
                else {
                    if ($columnType -eq "decimal" -or $columnType -eq "integer") {
                        $string += "$columnName = coalesce( :PARAM_$columnType" + "_$columnName , 0)"
                    }
                    elseif ($columnType -eq "date") {
                        $string += "$columnName = coalesce( cast( :PARAM_$columnType" + "_$columnName as date) , date '2999-12-31')"
                    }
                    else {
                        $string += "$columnName = coalesce( :PARAM_$columnType" + "_$columnName , '')"
                    }
                }
            }
        }
        else {
            if ($lineEnd -eq "WithJoin") {
                $string += "'$columnName = ' || cast( $columnType as varchar(255))"
            }
            elseif ($lineEnd -eq "WithJoinGen") {
                $string += "'$columnName = ' || coalesce(cast( $columnName as varchar(255)), '')"
            }
            else {
                $string += "$columnName = $columnType"
            }
        }

        if ($i -ne ($arrayColumn.Count-1)) {
            if ($lineEnd -eq "WithComma") {
                $string += " ,`n"
            }
            elseif ($lineEnd -eq "WithAnd") {
                $string += " and`n"
            }
            elseif ($lineEnd -eq "WithJoin" -or $lineEnd -eq "WithJoinGen") {
                $string += " || ' , ' || "
            }
        }
    }

    return $string
}