<#
    .SYNOPSIS
        Registers persistent environment variables for PS.Severance.
    .DESCRIPTION
        This script checks if the necessary persistent environment variables for PS.Severance are set.
        If not, it prompts the user to enter the required values and updates the PowerShell profiles accordingly.
        It ensures that the environment variables are consistently available across different PowerShell sessions.
#>
if ($null -eq $ENV:PSSEnvRoot) {
    $ENV:PSSEnvRoot = Read-Host -Prompt "PS.Severance: Enter the path for Environments Root (e.g., C:\Environments)"
    if ($null -eq $ENV:PSSEnvRoot) {
        throw "PS.Severance: Environments Root path is required."
    }
    if (-not (Test-Path $ENV:PSSEnvRoot)) {
        Try {
            New-Item -Path $ENV:PSSEnvRoot -ItemType Directory -Force | Out-Null
        }
        Catch {
            throw "PS.Severance: Failed to create the Environments Root path $($ENV:PSSEnvRoot): $_"
        }
    }
    $ENV:PSSConPrefix = "PS.S: "

    $PSSProfileRoot = Split-Path -Parent $PROFILE
    $PSConsoleProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
    $VSCodeProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.VSCode_profile.ps1"
    $PSSProfiles = @($PSConsoleProfile,$VSCodeProfile)

    Try {
        $IsProfileSet = Get-Content -Path $PSConsoleProfile -ErrorAction SilentlyContinue

        if ($null -eq $IsProfileSet -or $IsProfileSet -notmatch "`$ENV:PSSEnvRoot") {
            $PSSProfiles | Foreach {Add-Content -Path $_ -Value "`n# PS.Severance variable - Root path for PS.Severance environments`n`$ENV:PSSEnvRoot = `"$ENV:PSSEnvRoot`""}
            $Global:PSSFirstTimeRan = $true
        }
        if ($null -eq $IsProfileSet -or $IsProfileSet -notmatch "`$ENV:PSSConPrefix") {
            $PSSProfiles | Foreach {Add-Content -Path $_ -Value "`n# PS.Severance variable - Prefix for PS.Severance console title`n`$ENV:PSSConPrefix = `"$ENV:PSSConPrefix`""}
        }
        if ($null -eq $IsProfileSet -or $IsProfileSet -notmatch "`$ENV:PssWelcomeAscii") {
            $PSSProfiles | Foreach {Add-Content -Path $_ -Value "`n# PS.Severance variable - Enable PS.Severance welcome ASCII art`n`$ENV:PSSWelcomeAscii = `$True"}
        }
        if ($null -eq $IsProfileSet -or $IsProfileSet -notmatch "Import-Module PS.Severance") {
            $PSSProfiles | Foreach {Add-Content -Path $_ -Value "`n# Import PS.Severance module. This ensures that all functions and aliases are always available at the start of your session.`nImport-Module PS.Severance"}
        }
    }
    Catch {
        throw "PS.Severance: Failed to update PowerShell profiles: $_"
    }

}