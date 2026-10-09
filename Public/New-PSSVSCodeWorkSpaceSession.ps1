<#
    .SYNOPSIS
        Opens a Visual Studio Code workspace for a specified environment.

    .DESCRIPTION
        This function opens the Visual Studio Code workspace for the specified environment.
        It uses the environment's root folder as the workspace path.
        Recomended Extensions for PS.Severance to work as intended in VS Code include:
        - PowerShell (Microsoft)
        - Color Them Top Bars (Jeff Mathew)

        Bonus extensions that can enhance your development experience include:
        - Better Comments (Aaron Bond)
        - Colored Regions (mihelcic)
        - Show Unsaved Changes (ctf0)
        - Edit CSV (janisdd)
        - Rainbow CSV (mechatroner)
        - vscode-pdf (tomoki1207)

    .PARAMETER Environment
        The name of the environment.
    .EXAMPLE
        PS C:\> New-PSSVSCodeWorkSpaceSession -Environment "Development"
        Opens the Visual Studio Code workspace for the "Development" environment.

    .EXAMPLE
        PS C:\> PssVsc Production
        Opens the Visual Studio Code workspace for the "Production" environment. This uses alias `PssVsc` for the function.
#>
Function New-PSSVSCodeWorkSpaceSession {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment
    )

    Try {
        $WorkspacePath = "$ENV:PSSEnvRoot\$Environment"
        CODE $WorkspacePath
    }
    Catch {
        Write-Warning "Failed to open Visual Studio Code workspace for environment $($Environment): $_"
    }
}