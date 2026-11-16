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
        "## Welcome to PS.Severance! ##",
        "`nPS.Severance is initialized. You're ready to start creating isolated PowerShell environments.",
        "`nYour PowerShell and VS Code profiles:",
        "- $PSConsoleProfile",
        "- $VSCodeProfile",
        "`nUse these profiles to configure environment variables and other session settings.",
        "Restart the corresponding PowerShell session after making changes.",
        "`nStart severing:",
        "0. Explore commands with 'Get-Help <cmdlet> -Full'.",
        "1. Create an environment with 'New-PSSEnvironment'.",
        "2. Add or update environment variables with 'Update-PSSEnvVariable'.",
        "3. Add isolated modules with 'Install-PSSCustomModule'.",
        "4. Enter the environment in a PowerShell console with 'New-PSSConsole' (Alias: PSSCon).",
        "5. Open the environment in VS Code with 'New-PSSVSCodeWorkSpaceSession' (Alias: PSSVsc).",
        "`nEvery environment is severed from the others, with its own variables, command history, configuration, and optionally its own module versions.",
        "`nNeed this guide again? Run 'Invoke-PSSGetStarted'.",
        "Want the credits? Run 'Invoke-PSSVisual'.",
        "Want to uninstall PS.Severance? Run 'Uninstall-PSSeverance'.`n"

    $pswin = (Get-Host).UI.RawUI
    $pswinW = $pswin.WindowSize.Width
    $pswin.WindowTitle = "PS.S >_"

    Clear-Host
    $WelcomeReturn = New-Object System.Collections.ArrayList
    $LogoReturn = New-Object System.Collections.ArrayList
    $ascii = "█▀▀▄ ▄▀▀▀   ▄▀▀▀     ▀▄","█▀▀   ▀▀▄    ▀▀▄      ▄▀","▀    ▀▀▀  ▀ ▀▀▀      ▀   ▀▀▀▀"
    foreach ($line in $ascii) {
        $LineOut = ((" "*(($pswinW/2)-15)) + $line)
        [Void]$LogoReturn.Add($LineOut)
    }
    1..4 | Foreach-Object { [Void]$WelcomeReturn.Add("") }
    $WelcomeMessage | Foreach-Object { [Void]$WelcomeReturn.Add($_) }

    $LogoReturn | ForEach-Object { Write-PSSConsole $_ -ForegroundColor DarkGray }
    $WelcomeReturn | ForEach-Object { Write-PSSConsole $_ -ForegroundColor Green }
}