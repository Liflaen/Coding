
function Get-ColumnName {
    param (
        [string] $file
    )

    $gcFile = Get-Content $file
    $regex = '^\s.*'
    $r = ($gcFile | Select-String $regex -AllMatches)
    $notMatch = '\sprimary\s|index\s|column\s|comment\s|partition\s'
    $result = ($r | Select-String -notmatch $notMatch)

    ## Define array
    $arrayColumn = (0..($result.Count-1))

    ## Filling array with columns
    $i = 0
    foreach ($line in $result) {
        $arrayColumn[$i] = "$line".Split(' ')[1]
        $i++
    }

    return $arrayColumn
}

function Get-ColumnType {
    param (
        [string] $file
    )
    
    $gcFile = Get-Content $file
    $regex = '^\s.*'
    $r = ($gcFile | Select-String $regex -AllMatches)
    $notMatch = '\sprimary\s|index\s|column\s|comment\s|partition\s'
    $result = ($r | Select-String -notmatch $notMatch)

    ## Define array
    $arrayColumnType = (0..($result.Count-1))

    ## Filling array with types
    $i = 0
    foreach ($line in $result) {
        $splittedLine = "$line".Split(' ')[2]
        if ($splittedLine -like "*(*") { 
            $arrayColumnType[$i] = $splittedLine.Split('(')[0]
        }
        elseif ($splittedLine -like "*,") {
            $arrayColumnType[$i] = $splittedLine.Split(',')[0]
        }
        else {
            $arrayColumnType[$i] = $splittedLine
        }
        $i++
    }
    
    return $arrayColumnType
}

function Get-PrimaryIndex {
    param (
        [string] $file
    )

    $gcFile = Get-Content $file
    
    $regex = 'primary\sindex'
    $r = ($gcFile | Select-String $regex -AllMatches)
    $posStart = "$r".IndexOf("(")
    $posEnd = "$r".IndexOf(")")
    $end = $posEnd - $posStart
    $primaryIndex = "$r".Substring($posStart+1, $end-1)
    $indexCount = $primaryIndex.Split(',').Count

    ## Define array
    $arrayPrimaryIndex = (0..($indexCount-1))

    ## Filling array with columns
    for ($i=0; $i -ne $arrayPrimaryIndex.Count; $i++) {
        $arrayPrimaryIndex[$i] = ($primaryIndex.Split(',')[$i]).Trim()
    }

    return $arrayPrimaryIndex
}

function Get-NotNullColumnName {
    param (
        [string] $file
    )

    $gcFile = Get-Content $file
    $regex = '^\s.*'
    $r = ($gcFile | Select-String $regex -AllMatches)
    $notMatch = '\sprimary\s|index\s|column\s|comment\s|partition\s'
    $res = ($r | Select-String -notmatch $notMatch)
    $result = ($res | Select-String "not null" -AllMatches)

    $arraryNotNullColumn = (0..($result.Count-1))
    
    $i = 0
    foreach ($line in $result) {
        $arraryNotNullColumn[$i] = "$line".Split(' ')[1]
        $i++
    }

    return $arraryNotNullColumn
}

function Get-UpdatedColumnType {
    param (
        [string[]] $arrayType,
        [string[]] $arrayColumn
    )

    for ($i=0; $i -ne $arrayColumn.Count; $i++) {
        $elementType = $arrayType[$i].ToUpper()
        $elementColumn = $arrayColumn[$i]

        if ($elementType -eq "TIMESTAMP") {
            $elementType = "CURRENT_TIMESTAMP(0)"
        }
        elseif (($elementColumn -eq "Updated_By") -or ($elementColumn -eq "Created_By")) {
            $elementType = ":PARAM_CurrentUser"
        }
        elseif ($elementType -eq "BYTEINT") {
            $elementType = "SMALLINT"
        }

        $arrayType[$i] = $elementType
    }

    return $arrayType
}