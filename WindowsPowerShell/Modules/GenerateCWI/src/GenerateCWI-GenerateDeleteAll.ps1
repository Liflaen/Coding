function Generate-DeleteAll {
    param (
        [string] $tableName,
        [string] $databaseName,
        [string] $targetFile
    )

    ## Import DeleteAll xml structure
    $delete = Replace-StringInTemplate "::deleteAllRows::" $deleteAllRows $targetFile
    $delete | Out-File $targetFile

    ## Replace ::deleteAllFromOrig:: < delete all >
    $deleteAllFromOrig = "delete from $databaseName.$tableName;"
    $replaceDeleteAllFromOrig = Replace-StringInTemplate "::deleteAllFromOrig::" $deleteAllFromOrig $targetFile
    $replaceDeleteAllFromOrig | Out-File $targetFile
}