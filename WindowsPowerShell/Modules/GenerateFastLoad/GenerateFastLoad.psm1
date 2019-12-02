## Configuration
$target_OutDir = ".\target"
$ddl_InDir = ".\Development\TdDDLs"
$fastLoad_OutDir = Join-Path $target_OutDir "fastload"

function Clean-OutputDirectories {
    if (Test-Path $fastLoad_OutDir) {
        Remove-Item $fastLoad_OutDir -Recurse
        Write-Host "Cleaning Repository: $fastLoad_OutDir" 
    }
    Create-OutputDirectories
}

function Create-OutputDirectories {
    if (-not (Test-Path $target_OutDir)) {
        New-Item -Name "target" -ItemType "directory" -Force | Out-Null
        Write-Host "Creating New Empty Repository: $target_OutDir"
    }
    New-Item -Name "fastload" -Path $target_OutDir -ItemType "directory" -Force | Out-Null
    Write-Host "Creating New Empty Repository: $fastLoad_OutDir"
}

function Get-ColumnsName {
    param (
        [string] $file
    )

    $file_in = Get-Content $file
    $regex = '^\s.*'
    $r = ($file_in | Select-String $regex -AllMatches)
    $notMatch = '\sprimary\s|index\s|column\s|comment\s|partition\s'
    $res = ($r | Select-String -notmatch $notMatch)

    ## Define array
    $arrayOfColumns = (0..$res.Line.Length)
    
    ## Filling array with columns
    [int] $i = 0
    foreach ($line in $res) {
        $arrayOfColumns[$i] = "$line".Split(' ')[1]
        $i++
    }

    return $arrayOfColumns
}

function Get-DatabaseName {
    param (
        [string] $file
    )

    $file_in = Get-Content $file
    $r = $file_in | Select-String 'database\s'
    $res = ("$r".Split(' ')[1]).Split(';')[0]

    return $res
}

function Generate-FastLoadFile {
    param (
        [string] $nameOfTable,
        [string] $nameOfDB,
        [string[]] $arrayOfColumns,
        [int] $countOfLinesInArray,
        [string] $file
    )

    $variables = Get-Content "$PSScriptRoot\input.example"
    $userName             = $variables[2].split(":")[1]
    $teradataServer       = $variables[3].split(":")[1]
    $separator            = $variables[4].split(":")[1]
    $passwd               = $variables[7].split(":")[1]

    ## Config name of files etc.
    $nameOfTableErr1 = $nameOfTable + "_Err1"
    $nameOfTableErr2 = $nameOfTable + "_Err2"
    $nameOfOutputFile = $nameOfTable + ".fastload"

    if ($teradataServer -eq "test") { $tdServer = "tdtest8.kb.cz" }
    if ($teradataServer -eq "prod") { $tdServer = "tdprod.kb.cz" }

    ## Generate script 
    $logonString = ".SET SESSION CHARSET 'utf8'`n.logmech ldap`n.logon $tdServer/$userName,$passwd`n" 
    $logonString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
    
    $dropTableString = "database $nameOfDB;`n`ndrop table $nameOfTable;`ndrop table $nameOfTableErr1;`ndrop table $nameOfTableErr2;`n"
    $dropTableString | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    $file_in = Get-Content $file
    $file_in | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    $defineString = "`nset record vartext `"$separator`";`ndefine"
    $defineString | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    Get-ColumnsFromArray $countOfLinesInArray $arrayOfColumns 1

    $fileString = "file = $nameOfTable.txt;`nshow;`nbegin loading $nameOfTable errorfiles $nameOfTableErr1, $nameOfTableErr2;`n"
    $fileString | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    $insertString = "insert into $nameOfTable`n("
    $insertString | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    Get-ColumnsFromArray $countOfLinesInArray $arrayOfColumns 2

    $betweenInsertString = ")`nvalues`n("
    $betweenInsertString | Add-Content $fastLoad_OutDir\$nameOfOutputFile

    Get-ColumnsFromArray $countOfLinesInArray $arrayOfColumns 3

    $afterInsertString = ");`n`nend loading;`nlogoff;"
    $afterInsertString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
}

function Get-ColumnsFromArray {
    param (
        [int] $countOfLinesInArray,
        [string[]] $arrayOfColumns,
        [int] $phase
    )

    $variables = Get-Content "$PSScriptRoot\input.example"
    $lengthOfVarchar      = $variables[5].split(":")[1]
    $columnTypeInDefine      = $variables[6].split(":")[1]

    for ($j=0; $j -ne $countOfLinesInArray; $j++) {
        if ($arrayOfColumns[$j] -ne '') {
            $columnInArray = $arrayOfColumns[$j]
            if ($j -ne $countOfLinesInArray-1) {
                if ($phase -eq 1) {
                    $columnToVarcharString = " $columnInArray ($columnTypeInDefine($lengthOfVarchar)),"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                }
                if ($phase -eq 2) {
                    $columnToVarcharString = " $columnInArray,"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                }
                if ($phase -eq 3) {
                    $columnToVarcharString = " :$columnInArray,"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                }            
            }
            else {
                if ($phase -eq 1) {
                    $columnToVarcharString = " $columnInArray ($columnTypeInDefine($lengthOfVarchar))"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                }
                if ($phase -eq 2) {
                    $columnToVarcharString = " $columnInArray"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                }
                if ($phase -eq 3) {
                    $columnToVarcharString = " :$columnInArray"
                    $columnToVarcharString | Add-Content $fastLoad_OutDir\$nameOfOutputFile
                } 
            }
        }
    }
}

function Convert-GeneratedFastLoad {
    param (
        [string] $nameOfTable,
        [string] $nameOfDB
    )
    $variables = Get-Content "$PSScriptRoot\input.example"
    $databaseSufix        = $variables[0].split(":")[1]
    $tablePrefix          = $variables[1].split(":")[1]

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    $filePath = $fastLoad_OutDir+"\"+$nameOfTable+".fastload"

    $resolveFilePath = Resolve-Path $filePath

    $fastLoadFile = Get-Content $resolveFilePath -Encoding UTF8
    $tableReplace = $fastLoadFile -replace [regex]::escape("$nameOfTable"), ($tablePrefix+$nameOfTable)
    $dbReplace = $tableReplace -replace [regex]::escape("$nameOfDB"), ($nameOfDB+$databaseSufix)
    
    $finalReplace = $dbReplace -replace [regex]::escape("file = $tablePrefix$nameOfTable"), "file = $nameOfTable"
    [System.IO.File]::WriteAllLines($resolveFilePath, $finalReplace, $Utf8NoBomEncoding)
}

function Invoke-GenFastLoad {
    ## Syntax because of verbose
    [CmdletBinding()]
    param ()

    $cntProc = 0
    ## Clean of directories if exists
    Clean-OutputDirectories

    Write-Host "Generating Fastload Files"
    ## Work with each file in for cycle
    $inputFiles = Get-ChildItem $ddl_InDir -Recurse -Filter 'table.*' | Sort-Object
    foreach ($file in $inputFiles) {
        ## Get columns from ddl
        Write-Verbose " $file"
        $arrayOfColumns = Get-ColumnsName $file.FullName

        ## Get count of lines in array
        $countOfLinesInArray = 0
        for ($i=0; $i -ne $arrayOfColumns.Length; $i++) {
            if ($arrayOfColumns[$i] -isnot [int]) {
                $countOfLinesInArray++
            }
        }
        
        ## Get name of table
        $nameOfTable = $file.Name.Split('.')[1]

        ## Get Database name
        $nameOfDB = Get-DatabaseName $file.FullName

        ## Generate fastload file
        New-Item -Name ($nameOfTable + ".fastload") -Path $fastLoad_OutDir -Force | Out-Null
        Generate-FastLoadFile $nameOfTable $nameOfDB $arrayOfColumns $countOfLinesInArray $file.FullName
        Convert-GeneratedFastLoad $nameOfTable $nameOfDB
        Write-Progress -Activity "Generating Fastload Files" -Status "Running" -PercentComplete ($cntProc++/($inputFiles.Count)*100)
    }
    Write-Progress -Activity "Generating Fastload Files" -Status "Done" -Completed
} 