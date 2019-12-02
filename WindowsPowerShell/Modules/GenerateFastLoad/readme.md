# Instalation
* Install using powershell:
  * Copy or checkout to location on path from `$Env:PsModulePath`
  * example: `C:\Users\user\Documents\WindowsPowerShell\Modules\GenerateFastLoad`
  * call `Import-Module GenerateFastLoad`
    * https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module?view=powershell-6

# Usage
* in Git repository call:
Invoke-GenFastLoad -Verbose

* This will generate from all DDL files "table.*" fastload scripts.

# Parameters
 * You can change input variables in "input.example" like enviroment, username etc.
 * if u have different git repository structure u have to change begin of .psm1 file ( ## Configuration )
