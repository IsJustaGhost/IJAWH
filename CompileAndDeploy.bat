:: This script will
::   - Create a .zip-file containing all addon files
::   - Copy the addon to ESO's live\AddOn folder
:: @PowerShell.exe -NoExit -ExecutionPolicy Bypass -File "..\Framework\PowerShell\CompileAndDeploy.ps1" "%cd%"
@PowerShell.exe -ExecutionPolicy Bypass -File "..\Framework\PowerShell\CompileAndDeploy.ps1" "%cd%"