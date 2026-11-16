<#
    .SYNOPSIS
        Installs the specified parts of the PS.Severance environment.

    .DESCRIPTION
        This function installs the requested components of the PS.Severance environment, including VSCode, VSCode extensions, and the PowerShell profile.

    .PARAMETER Part
        Specifies which parts to install. Valid values are 'All', 'VSCode', 'VSCodeExtensions', and 'PowerShellProfile'.
        If 'All' is specified, all components will be installed.
        Multiple parts can be specified by providing an array of values.
        The function will process each specified part and attempt to install it accordingly.

    .EXAMPLE
        Install-PSSDependency -Part 'All'
        This will install all components of the PS.Severance environment.

    .EXAMPLE
        Install-PSSDependency -Part 'VSCode','PowerShellProfile'
        This will install only the VSCode and PowerShell profile components of the PS.Severance environment.
#>
Function Install-PSSDependency {
    [cmdletbinding(supportsshouldprocess=$true)]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('All', 'VSCode', 'VSCodeExtensions', 'PowerShellProfile')]
        [array]$Part
    )

    if ($Part -contains 'All') {
        [array]$Parts = 'VSCode','VSCodeExtensions','PowerShellProfile'
    }
    else {
        [array]$Parts = $Part
    }

    Foreach ($part in $Parts) {
        switch ($part) {
            'VSCode' {
                # Install Newest VSCode version
                Try {
                    if (Get-Command winget -ErrorAction SilentlyContinue) {
                        # Install VSCode using winget if available
                        winget install --id Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements

                        #Refresh Environmental variables to ensure VSCode is available in the current session
                        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +[System.Environment]::GetEnvironmentVariable('Path', 'User')
                    }
                    else {
                        Write-Warning "PS.Severance: 'winget' command not found. Skipping VSCode installation.`nConsider installing VSCode manually."
                    }
                }
                Catch {
                    Write-Warning "PS.Severance: Failed to install VSCode: $_"
                }
            }
            'VSCodeExtensions' {
                # Install VSCode extensions
                Try {
                    # Attempt to install the VSCode extension for coloring top bars
                    if (Get-Command Code -ErrorAction SilentlyContinue) {
                        Code --install-extension jeffmathew.vscode-color-them-top-bars
                    }
                    else {
                        Write-Warning "PS.Severance: VSCode command 'Code' not found. VSCode might not be installed."
                        $InstallVSCode = Read-Host -Prompt "PS.Severance: Do you want to install VSCode now? (Y/N)"
                        if ($InstallVSCode -eq 'Y') {
                            Install-PSSDependency -Part 'VSCode','VSCodeExtensions'
                        }
                    }
                }
                Catch {
                    Write-Warning "PS.Severance: Failed to install VSCode extension 'jeffmathew.vscode-color-them-top-bars': $_"
                    Write-PssConsole "Try again later by running 'Install-PSSDependency -Part 'VSCodeExtensions'' or from VSCode directly." -ForegroundColor White
                }
            }
            'PowerShellProfile' {
                Try {
                    # Install PowerShell profile
                    $PSSProfileRoot = Split-Path -Parent $PROFILE
                    $PSConsoleProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
                    $VSCodeProfile = Join-Path -Path $PSSProfileRoot -ChildPath "Microsoft.VSCode_profile.ps1"
                    $PSSProfiles = @($PSConsoleProfile,$VSCodeProfile)

                    Foreach ($PSSprofile in $PSSProfiles) {
                        # Ensure the profile file exists and create it if it doesn't
                        if (-Not (Test-Path -Path $PSSprofile)) {
                            New-Item -Path $PSSprofile -ItemType File -Force
                        }
                        # Get the current content of the profile file
                        $ProfileContent = Get-Content -Path $PSSprofile -ErrorAction SilentlyContinue

                        # Check if the profile already contains the PS.Severance environment variables and module import. Add them if they are missing.
                        if ($null -eq $ProfileContent -or $ProfileContent -notmatch "`$ENV:PSSEnvRoot") {
                            Add-Content -Path $PSSprofile -Value "`n# PS.Severance variable - Root path for PS.Severance environments`n`$ENV:PSSEnvRoot = `"$ENV:PSSEnvRoot`""
                        }
                        if ($null -eq $ProfileContent -or $ProfileContent -notmatch "`$ENV:PSSConPrefix") {
                            Add-Content -Path $PSSprofile -Value "`n# PS.Severance variable - Prefix for PS.Severance console title`n`$ENV:PSSConPrefix = `"$ENV:PSSConPrefix`""
                        }
                        if ($null -eq $ProfileContent -or $ProfileContent -notmatch "`$ENV:PSSWelcomeAscii") {
                            Add-Content -Path $PSSprofile -Value "`n# PS.Severance variable - Enable PS.Severance welcome ASCII art`n`$ENV:PSSWelcomeAscii = `$True"
                        }
                        if ($null -eq $ProfileContent -or $ProfileContent -notmatch "Import-Module PS.Severance") {
                            Add-Content -Path $PSSprofile -Value "`n# Import PS.Severance module. This ensures that all functions and aliases are always available at the start of your session.`nImport-Module PS.Severance"
                        }
                    }
                }
                Catch {
                    throw "PS.Severance: Failed to install PowerShell profile: $_"
                }
            }
        }
    }
}