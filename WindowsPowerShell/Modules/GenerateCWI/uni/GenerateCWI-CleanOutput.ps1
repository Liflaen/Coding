function Clean-OutputDirectory {
    if (Test-Path $cwiReport_OutDir) {
        Remove-Item $cwiReport_OutDir -Recurse
        Write-Host "Cleaning Repository: $cwiReport_OutDir" 
    }
    Create-OutputDirectory
}

function Create-OutputDirectory {
    if (-not (Test-Path $target_OutDir)) {
        New-Item -Name "target" -ItemType "directory" -Force | Out-Null
        Write-Host "Creating New Empty Repository: $target_OutDir"
    }
    New-Item -Name "cwi_reports" -Path $target_OutDir -ItemType "directory" -Force | Out-Null
    Write-Host "Creating New Empty Repository: $cwiReport_OutDir"
}