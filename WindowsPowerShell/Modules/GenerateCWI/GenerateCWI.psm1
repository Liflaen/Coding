## Configuration
$target_OutDir = ".\target"
$ddl_InDir = ".\Development\TdDDLs"
$ddl_InDir_Excl = ".\ExDDL"
$cwiReport_OutDir = Join-Path $target_OutDir "cwi_reports"
$singleLogName = "CWI_Event_Journal"

## Import src
. $PSScriptRoot\src\GenerateCWI-GenerateSelect.ps1
. $PSScriptRoot\src\GenerateCWI-GenerateInsert.ps1
. $PSScriptRoot\src\GenerateCWI-GenerateUpdate.ps1
. $PSScriptRoot\src\GenerateCWI-GenerateDelete.ps1
. $PSScriptRoot\src\GenerateCWI-GenerateDeleteAll.ps1
. $PSScriptRoot\src\GenerateCWI-GenerateImport.ps1

## Import uni
. $PSScriptRoot\uni\GenerateCWI-Replace.ps1
. $PSScriptRoot\uni\GenerateCWI-Column.ps1
. $PSScriptRoot\uni\GenerateCWI-Array.ps1
. $PSScriptRoot\uni\GenerateCWI-CleanOutput.ps1
. $PSScriptRoot\uni\GenerateCWI-Database.ps1
. $PSScriptRoot\uni\GenerateCWI-Specific.ps1
. $PSScriptRoot\uni\GenerateCWI-MultiUse.ps1

## Import main structure of xml
$mainTemplate = Get-Content "$PSScriptRoot\xml-definition\mainTemplate.example" -Raw
$mainInsert = Get-Content "$PSScriptRoot\xml-definition\insert.example" -Raw
$mainUpdate = Get-Content "$PSScriptRoot\xml-definition\update.example" -Raw
$deleteSingle = Get-Content "$PSScriptRoot\xml-definition\deleteSingleRow.example" -Raw
$deleteMulti = Get-Content "$PSScriptRoot\xml-definition\deleteMultiRow.example" -Raw
$deleteAllRows = Get-Content "$PSScriptRoot\xml-definition\deleteAllRows.example" -Raw
$mainImport = Get-Content "$PSScriptRoot\xml-definition\import.example" -Raw

## Import other structure of xml
$columnDefinitionBean = Get-Content "$PSScriptRoot\xml-definition\columnDefinition.example" -Raw
$columnDefinitionPIndexBean = Get-Content "$PSScriptRoot\xml-definition\columnDefinitionPIndex.example" -Raw
$columnValueBean = Get-Content "$PSScriptRoot\xml-definition\columnValueBean.example" -Raw
$columnNotNulValidation = Get-Content "$PSScriptRoot\xml-definition\validationNotNullColumns.example" -Raw

function Invoke-GenCWIReport {
    [CmdletBinding()]
    param (
        [Alias("a")][switch] $all,
		[Alias("s")][switch] $select,
		[Alias("i")][switch] $insert,
		[Alias("u")][switch] $update,
		[Alias("d")][switch] $delete,
		[Alias("da")][switch] $deleteAll,
        [Alias("im")][switch] $import,
        # Single log = one log for all tables, multi log = every table has his own log table
        [Alias("sl")][switch] $singleLog,
        [Alias("ml")][switch] $multiLog,
        [Alias("x")][switch] $excluded
	)

    $cntProc = 0
    Clean-OutputDirectory

    if ($excluded) {
        $gciFile = Get-ChildItem $ddl_InDir_Excl -Recurse -Include "*.sql"
    }
    else {
        $gciFile = Get-ChildItem $ddl_InDir -Recurse -Include "*.sql"
    }

    Write-Host "Generating CWI Reports"
    foreach ($file in $gciFile) {
        $tableName = $file.Name.Split('.')[1]
        $targetFile = $cwiReport_OutDir+"\"+$tableName+".xml"
        
        Write-Verbose " $targetFile"

        $arrayColumn = Get-ColumnName $file
        $arrayColumnType = Get-ColumnType $file
        $arrayPrimaryIndex = Get-PrimaryIndex $file
        $arraryNotNullColumn = Get-NotNullColumnName $file
        $arrayColumnTypeUpdated = Get-UpdatedColumnType $arrayColumnType $arrayColumn

        $databaseName = Get-DatabaseName $file

        ## Insert empty template < main >
        $mainTemplate | Add-Content $targetFile

        if ($select -or $all) {
            Generate-Select $tableName $databaseName $targetFile $arrayColumn $arrayColumnType $arrayPrimaryIndex
        }
        if ($insert -or $all) {
            Generate-Insert $tableName $databaseName $targetFile $arrayColumn $arrayPrimaryIndex $arrayColumnTypeUpdated $arraryNotNullColumn
        }
        if ($update -or $all) {
            Generate-Update $tableName $databaseName $targetFile $arrayColumn $arrayPrimaryIndex $arraryNotNullColumn $arrayColumnTypeUpdated
        }
        if ($delete -or $all) {
            Generate-Delete $tableName $databaseName $targetFile $arrayPrimaryIndex $arrayColumnTypeUpdated $arrayColumn
        }
        if ($deleteAll -or $all) {
            Generate-DeleteAll $tableName $databaseName $targetFile
        }
        if ($import -or $all) {
            Generate-Import $tableName $databaseName $targetFile $arrayColumn $arrayPrimaryIndex $arrayColumnTypeUpdated
        }

        ## Replace multi XML structure - final
        Replace-AllMultiXMLStructure $tableName $databaseName $targetFile $singleLog $multiLog $arrayColumn $arrayPrimaryIndex $arrayColumnTypeUpdated $arraryNotNullColumn
        
        Write-Progress -Activity "Generating CWI Reports" -Status "Running" -PercentComplete ($cntProc++/($gciFile.Count)*100)
    }
    Write-Progress -Activity "Generating CWI Reports" -Status "Done" -Completed
}