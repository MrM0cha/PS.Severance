<#
    .SYNOPSIS
        Opens a new PowerShell console window with a specified environment.

    .DESCRIPTION
        This function prompts the user for a console name if no environment is specified.
        If an environment is specified, it reads the console color from the environment's VSCode settings
        and opens a new Windows Terminal tab with the specified color and title.
        Module main script constructs the necessary parameters based on the environment and user input,
        and then opens the new console window with the specified environment settings.

    .PARAMETER Environment
        The name of the environment for which to open a new console window.
        If not specified, the user will be prompted to enter a console name.

    .EXAMPLE
        PS C:\> New-PSSConsole -Environment "Development"
        Opens a new Windows Terminal tab for the "Development" environment with the appropriate color and title.
    
    .EXAMPLE
        PS C:\> PssCon Production
        Opens a new Windows Terminal tab for the "Production" environment with the appropriate color and title. This uses alias `PssCon` for the function.
    
    .EXAMPLE
        PS C:\> New-PSSConsole
        Prompts the user for a console name and opens a new PowerShell console window with the specified name.
#>
Function New-PSSConsole {
    Param (
        $Environment
    )
    if (!$Environment) {
        Try {
            $con = Read-Host "Console Name"
            $pswin = (Get-Host).UI.RawUI
            $pswinW = $pswin.WindowSize.Width
            $pswin.WindowTitle = $con
            cls
        }
        Catch {
            throw "Failed to open new PowerShell console window: $_"
        }
    }
    else {
        Try {
            $ConsoleColor = (Get-Content "$ENV:PSSEnvRoot\$Environment\.vscode\settings.json" | ConvertFrom-Json).'workbench.colorCustomizations'.'titleBar.activeBackground'
            wt -w 0 --tabColor $ConsoleColor --title "$($ENV:PSSConPrefix)$($Environment)"
        }
        Catch {
            throw "Failed to open new Windows Terminal tab for environment $($Environment): $_"
        }
    }
}