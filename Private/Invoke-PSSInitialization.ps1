<#
    .SYNOPSIS
        Initializes the PS.Severance environment by ensuring required persistent environment variables are set.
    .DESCRIPTION
        This script ensures that the PS.Severance environment is properly initialized
        by setting up required persistent environment variables and updating PowerShell profiles as needed.
#>
if ($null -eq $ENV:PSSEnvRoot) {
    $ENV:PSSEnvRoot = Read-Host -Prompt "PS.Severance: Enter the path for Environments Root (e.g., C:\Environments)"
    # Remove any trailing backslashes from the path
    $ENV:PSSEnvRoot = $ENV:PSSEnvRoot.TrimEnd('\')

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
        $IsProfileSet = $true
        Foreach ($PSSProfile in $PSSProfiles) {
            $PSSProfileContent = Get-Content -Path $PSSProfile -ErrorAction SilentlyContinue
            if ($null -eq $PSSProfileContent -or $PSSProfileContent -notmatch "`$ENV:PSSEnvRoot") {$IsProfileSet = $false}
        }
        if ($IsProfileSet -eq $false) {
            $Script:PSSFirstTimeRan = $true
            # Install dependencies. Try Profile and VSCode extensions first
            $InstallScriptLocation  = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Public\Install-PSSDependency.ps1"
            . $InstallScriptLocation
            Install-PSSDependency -Part 'PowerShellProfile','VSCodeExtensions'
        }
    }
    Catch {
        throw "PS.Severance: Failed to update PowerShell profiles: $_"
    }
}