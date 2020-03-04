## Configuration
$target_OutDir = ".\target"
$ddl_InDir = ".\Development\TdDDLs"
<# $ddl_InDir = ".\Development\TdDDLs\shoper_alm" #>
$cwiReport_OutDir = Join-Path $target_OutDir "cwi_reports"
$singleLogName = "CWI_Event_Journal"
#$table_filter = "table.C_*"

## Import src
#. $PSScriptRoot\src\GenerateCWI-GenerateFile.ps1
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
		[Alias("s")][switch] $select,
		[Alias("i")][switch] $insert,
		[Alias("u")][switch] $update,
		[Alias("d")][switch] $delete,
		[Alias("da")][switch] $deleteAll,
        [Alias("im")][switch] $import,
        [Alias("a")][switch] $all,
        # Single log = one log for all tables, multi log = every table has his own log table
        [Alias("sl")][switch] $singleLog,
        [Alias("ml")][switch] $multiLog,
        [Alias("f")][switch] $financ,
        [Alias("h")][switch] $hypo,
        [Alias("c")][switch] $calc
	)

    $cntProc = 0
    Clean-OutputDirectory
    if ($hypo) {
        $gciFile = Get-ChildItem $ddl_InDir -Recurse -Include "table.C_Bond_Type.sql" ,
        "table.Block_Related_Debt.sql" ,
        "table.C_Cover_Block.sql" ,
        "table.C_Source_Definition.sql" ,
        "table.Config_Parameter_Value.sql" ,
        "table.CWI_Event_Journal.sql" ,
        "table.Manual_Correction.sql" ,
        "table.Manual_Priority.sql" ,
        "table.Mortgage_Certificate.sql" ,
        "table.R_Block_Parameter.sql" ,
        "table.R_Filtering_Rule.sql" ,
        "table.R_ISIN_Block.sql" ,
        "table.Reconstruction_Request.sql" ,
        "table.Substitute_Cover.sql" ,
        "table.T_Cover_Block_Product_Type.sql" | Sort-Object
    }
    
    if ($financ) {
        $gciFile = Get-ChildItem $ddl_InDir -Recurse -Include "table.C_ALM_Index_Rate.sql" ,
        "table.C_ALM_Product.sql" ,
        "table.C_ALM_Product_Replication.sql" ,
        "table.C_Calculation_Type.sql" ,
        "table.C_Error.sql" ,
        "table.C_Liquidity_Segment_Ext.sql" ,
        "table.C_Parameter.sql" ,
        "table.C_Repayment_Type.sql" ,
        "table.C_SG_Party_RCT.sql" ,
        "table.C_Schedule_Type.sql" ,
        "table.C_Source.sql" ,
        "table.C_Source_Hierarchy.sql" ,
        "table.MD_Snake_Script.sql" ,
        "table.MD_Source_Parameter_Rel.sql" ,
        "table.Process_Manual_Request.sql" ,
        "table.R_ALM_EIB_Hedge.sql" ,
        "table.R_ALM_Parameter.sql" ,
        "table.R_ALM_Parameter_Constant.sql" ,
        "table.R_ALM_Segmentation_EIS.sql" ,
        "table.R_B3_Segmentation.sql" ,
        "table.R_BHFM_Segmentation.sql" ,
        "table.R_CTR_Segmentation.sql" ,
        "table.R_GL_Pooling_Account_Corr.sql" ,
        "table.R_IFRS_Prod.sql" ,
        "table.R_Interest_Rate_Range.sql" ,
        "table.R_Ledger_Branch_Book_Value.sql" ,
        "table.R_Ledger_Branch_BT.sql" ,
        "table.R_Model_Product.sql" ,
        "table.R_Source_Dependency.sql" ,
        "table.T_Individual_Rate_Flag_AT.sql" ,
        "table.R_Account_Nbr_On_List.sql" | Sort-Object
    }

    if ($calc) {
        $gciFile = Get-ChildItem $ddl_InDir -Recurse -Include "table.HC_Hair_Cut.sql" ,
        "table.HC_Sensitivity.sql" ,
        "table.HC_Vectors.sql" ,
        "table.MD_VBS_Process_Request.sql" ,
        "table.C_Start_Point.sql" | Sort-Object
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
        #$arrayAllowNullColumn = $arrayColumn | {$arraryNotNullColumn -notcontains $_}

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