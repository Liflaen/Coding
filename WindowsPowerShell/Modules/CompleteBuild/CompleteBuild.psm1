# input variables
function WaitKeyPress
{
  param(
    [string] $textMessage
  )

  Write-Host "$textMessage" -ForegroundColor Green
  $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function ColorMessage {
  param (
    [string] $writeHost
  )

  Write-Host $writeHost -ForegroundColor Green
}

function Complete-Build {
  param (
    [string] $xmlPath,
    [string] $sedPath,
    [string] $logonPath
  )
  Write-Host "Generate objects" -ForegroundColor Green
  Invoke-TargetGenerate $xmlPath $sedPath -d -i -s -f -c -verbose
  
  <# WaitKeyPress "Validate objects and then press a SPACEBAR to continue." #>
  
  ColorMessage "Deploy objects"
  Invoke-TargetDeploy $xmlPath $logonPath -d -verbose
  
  ColorMessage "Verify scripts"
  Invoke-TargetVerify $xmlPath $logonPath -s -verbose
  
  ColorMessage "Copy scripts to informatica folder"
  Invoke-TargetDeploy $xmlPath $logonPath -s -verbose
  
  ColorMessage "Copy workflow into informatica server"
  Invoke-TargetDeploy $xmlPath $logonPath -f -verbose
  
  ColorMessage "Execute inits -ib"
  Invoke-TargetExecute $xmlPath $logonPath -ib -verbose
  
  ColorMessage "Execute inits -ie"
  Invoke-TargetExecute $xmlPath $logonPath -ie -verbose
}

<# function Clean-AfterBuild {
  param (
    [string] $xmlPath,
    [string] $sedPath,
    [string] $logonPath
  )

  ColorMessage "Clean enviroment"
  Invoke-TargetClean $xmlPath $logonPath -d -verbose
} #>

function Invoke-CompleteBuild {
  [CmdletBinding()]
	param (
		[Alias("h")][switch] $hypo,
		[Alias("f")][switch] $finance
  )
  if ($hypo) {
    $xmlPath = "c:\Users\ttintera\!Data\dmt-m_hypo\Deployment\solution.xml"
    $sedPath = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.sed.example"
  }
  if ($finance) {
    $xmlPath = "c:\Users\ttintera\!Data\dmt-finance-data-solution\Deployment\solution.xml"
    $sedPath = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.sed_f.example"
  }
  $logonPath = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.xml.example"

  Complete-Build $xmlPath $sedPath $logonPath
  <# Clean-AfterBuild $xmlPath $sedPath $logonPath #>
}