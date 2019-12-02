Import-Module posh-git
Import-Module TDBuild -Force
Import-Module CompleteBuild -Force
Import-Module GenerateFastLoad -Force -DisableNameChecking
Import-Module GenerateCWI -Force -DisableNameChecking

$solutionHypo = "c:\Users\ttintera\!Data\dmt-m_hypo\Deployment\solution.xml"
$solutionFinance = "c:\Users\ttintera\!Data\dmt-finance-data-solution\Deployment\solution.xml"

$sedHypo = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.sed.example"
$sedFinance = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.sed_f.example"

$xmlPasswd = "c:\Users\ttintera\Documents\WindowsPowerShell\env_qa.xml.example"

function set-completeBuildHypo {
    invoke-completebuild -h -verbose
}
Set-Alias icbh set-completeBuildHypo

function set-completeBuildFinance {
    invoke-completebuild -f -verbose
}
Set-Alias icbf set-completeBuildFinance
function get-gitstatus {
    git status
}
Set-Alias gs get-gitstatus

function get-gitcheckout {
    param(
        [string]$branchName
    )
    git checkout $branchName
}
Set-Alias go get-gitcheckout

function get-gitpullr {
    git pull -r
}
Set-Alias gr get-gitpullr

function get-gitlogoneline {
    git log --oneline
}
Set-Alias glo get-gitlogoneline

function get-gitpushforcewithlease {
    git push --force-with-lease
}
Set-Alias gpfw get-gitpushforcewithlease

function get-gitcommitm {
    param (
        [string] $message
    )
    git commit -m $message
}
Set-Alias gcom get-gitcommitm

Write-Host "Profile import finished!" -ForegroundColor Green