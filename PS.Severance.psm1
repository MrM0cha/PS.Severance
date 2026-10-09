<#
.SYNOPSIS
PSSeverance is a custom module for handling multiple PowerShell environments and their configurations.

.DESCRIPTION
This module contains several functions that facilitate the management and configuration of multiple PowerShell environments.
It severes the management and configuration between different PowerShell environments, e.g. Console name and color, Environmental variables, command history, and module versions

.NOTES

Author:         Teemu "Mokka" Kettunen
Creation Date:  18.09.2026
Last Update:    18.09.2026

#>
$ErrorActionPreference = "Stop"

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1)
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1)

#Dot source the files
Foreach($import in ($Private+$Public)) #@($Public + $Private)
{
    Try {
        . $import.fullname #-ExecutionPolicy Bypass
    }
    Catch {
        Throw "Failed to import function $($import.fullname): $_"
    }
}
Try {
    $PSSLocation = ((Get-Location).Path -replace '\\',"/") -match ($env:PSSEnvRoot -replace '\\',"/")
    if ($PSSLocation) {
        $PssConsoleTitle = ((Get-Location).Path -split "\\") | select -Last 1
    }
    else {
        $PssConsoleTitle = ($PssConsoleTitle.ToString() -replace "$ENV:PSSConPrefix ")
    }
}
Catch {
    Throw "Failed to determine Environment using current location or console title: $_"
}

$CmdletAliasMatrix = @{
    "UPSSEV" = "Update-PSSEnvVariables"
    "GPSSEV" = "Get-PSSEnvVariables"
    "PssCon"    = "New-PSSConsole"
    "NPSSEV" = "New-PSSEnvVariables"
    "PssVsc"   = "New-PSSVSCodeWorkSpaceSession"
    "PSSWelcome" = "Invoke-PssWelcome"
}
Try {
    Foreach ($PublicFunction in $Public.Basename) {
        if ($CmdletAliasMatrix.ContainsValue($PublicFunction)) {
            $Alias = ($CmdletAliasMatrix.GetEnumerator() | Where-Object { $_.Value -eq $PublicFunction }).Key
            Set-Alias -Name $Alias -Value $PublicFunction
            Export-ModuleMember -Function $PublicFunction -Alias $Alias
        }
        else {
            Export-ModuleMember -Function $PublicFunction
        }
    }
}
Catch {
    Throw "Failed to set up module aliases and export functions: $_"
}

Try {
    if ($PssConsoleTitle -notmatch "PowerShell|pwsh") {
        Get-PSSEnvVariables -Environment $PssConsoleTitle -ErrorAction SilentlyContinue
        if ((Get-Location).Path -ne "$ENV:PSSEnvRoot\$PssConsoleTitle") { Set-Location "$ENV:PSSEnvRoot\$PssConsoleTitle" -ErrorAction SilentlyContinue }
        Set-PSReadLineOption -HistorySavePath .\CommandHistory.txt -ErrorAction SilentlyContinue

        if ($UseCustomModuleVersions -eq "True") {
            $CustomModulePath = "$ENV:PSSEnvRoot\$PssConsoleTitle\CustomModules"
            if (Test-Path $CustomModulePath) {
                $CustomModules = Get-ChildItem -Path $CustomModulePath -Directory
                Foreach ($CustomModule in $CustomModules) {
                    Remove-Module -Name $CustomModule.Name -ErrorAction SilentlyContinue
                    Import-Module $CustomModule.FullName -Scope Global -Force -ErrorAction Continue
                }
            }
        }
    }
    Elseif ($ENV:PssWelcomeAscii) {
        Invoke-PssWelcome
    }
}
Catch {
    Throw "Failed to initialize environment $($PssConsoleTitle): $_"
}

if ($PSSFirstTimeRan) {Invoke-PSSGetStarted}