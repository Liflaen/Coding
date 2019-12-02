function Get-DatabaseName {
    param (
        [string] $file
    )

    $gcFile = Get-Content $file
    $r = $gcFile | Select-String 'database\s'
    $result = ("$r".Split(' ')[1]).Split(';')[0]

    return $result
}