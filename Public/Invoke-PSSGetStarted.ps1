<#
    .SYNOPSIS
        Displays a welcome message and getting started guide for PS.Severance.
    .DESCRIPTION
        This function provides a friendly introduction to PS.Severance, including information about registered environment variables,
        PowerShell profiles, and step-by-step instructions for getting started with the module.
#>

Function Invoke-PSSGetStarted {

    $PSSProfileRoot = Split-Path -Parent $PROFILE
    $PSConsoleProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
    $VSCodeProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.VSCode_profile.ps1"

    $WelcomeMessage = 
        "Welcome to PS.Severance!",
        "`nRequired Global environment variables have been registered successfully for the first time.",
        "If you want to make changes to the environment variables, you can edit your PowerShell profile accordingly.",
        "Profiles:",
        "- $PSConsoleProfile",
        "- $VSCodeProfile",
        "You may need to restart your PowerShell session for the changes to take effect.",
        "`nHere's how to get started with PS.Severance:",
        "0. Use 'Get-Help <cmdlet>' to explore available cmdlets and their usage.",
        "1. Create a new environment using the 'New-PSSEnvironment' cmdlet.",
        "2. Add more environment variables as needed using the 'Update-PSSEnvVariables' cmdlet.",
        "3. Install any custom modules for the environment as needed using 'Install-PSSCustomModule' cmdlet.",
        "4. Connect to the new environment's console using 'New-PSSConsole' (Alias: PssCon) cmdlet.",
        "5. Connect to the new environment's VSCode workspace using 'New-PSSVSCode' (Alias: PssVSCode) cmdlet.",
        "6. Enjoy managing your Severed PowerShell environments with PS.Severance.",
        "`nEvery Environment you create will have its own isolated set of variables, command history, and configurations.",
        "If you plan to use CustomModules process, you can fully isolate module versions for each environment.",
        "`nTo return to this guide at any time, run 'Invoke-PSSGetStarted' cmdlet.",
        "To roll the credits, run 'Invoke-PSSCredits' cmdlet.",
        "To uninstall PS.Severance, Simply run 'Uninstall-PSSeverance' cmdlet.`n"
            
    $pswin = (Get-Host).UI.RawUI
    $pswinW = $pswin.WindowSize.Width
    $pswin.WindowTitle = "PS.S >_"

    $ascii = "█▀▀▄ ▄▀▀▀   ▄▀▀▀     ▀▄","█▀▀   ▀▀▄    ▀▀▄      ▄▀","▀    ▀▀▀  ▀ ▀▀▀      ▀   ▀▀▀▀"
    cls
    foreach ($line in $ascii) {
        Write-Host (" "*(($pswinW/2)-15)) $line -ForegroundColor DarkGray
    }
    1..4 | foreach {Write-Output ""}
    $WelcomeMessage | Foreach-Object { Write-Host $_ -foregroundcolor Green }
}