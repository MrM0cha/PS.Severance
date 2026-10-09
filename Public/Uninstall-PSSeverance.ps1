<#
    .SYNOPSIS
        Uninstalls the PS.Severance module and removes related profile entries.

    .DESCRIPTION
        This function removes all installed instances of the PS.Severance module and cleans up any related entries in the user's PowerShell profile files.
        No environments are removed by this function. You may manually delete them from $ENV:PSSEnvRoot.
        No unrelated files or settings are removed by this function.
#>
Function Uninstall-PSSeverance {

    # Confirmation
    $Confirmation = Read-Host "Are you sure you want to uninstall PS.Severance and remove related profile entries? (Y/N)"
    If ($Confirmation -eq "Y") {
    } Else {
        Write-Host "Uninstallation cancelled." -ForegroundColor Yellow
        Return
    }

    $Modules = Get-Module -Name PS.Severance -ListAvailable
    If ($Modules) {
        Foreach ($Module in $Modules) {
            Remove-Item -Path $Module.ModuleBase -Recurse -Force
        }
    }
    $PSSProfileCode = @(
        '# PS.Severance variable - ',
        'PSSEnvRoot = ',
        'PSSConPrefix = ',
        'PSSWelcomeAscii = ',
        'Import-Module PS.Severance',
        '# Import PS.Severance module.'
    )
    $PSSProfileMatch = [System.String]::Join("|", $PSSProfileCode)

    $PSSProfileRoot = Split-Path -Parent $PROFILE
    $PSConsoleProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
    $VSCodeProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.VSCode_profile.ps1"
    $PSSProfiles = @($PSConsoleProfile,$VSCodeProfile)

    If (Test-Path -Path $PSConsoleProfile) {
        Foreach ($PSSProfile in $PSSProfiles) {
            If (Test-Path -Path $PSSProfile) {
                $ProfileContent = Get-Content -Path $PSSProfile
                $NewProfileContent = $ProfileContent | where {$_ -notmatch $PSSProfileMatch} | where {$_ -ne ""}

                Set-Content -Path $PSSProfile -Value $NewProfileContent
            }
        }
    }

    Write-Host "PS.Severance has been uninstalled and profile entries removed." -ForegroundColor Green
    Write-Host "No Environments have been removed. You may manually delete them from $ENV:PSSEnvRoot." -ForegroundColor Green
    Write-Host "Remember to restart your PowerShell session for changes to take effect." -ForegroundColor Yellow
}