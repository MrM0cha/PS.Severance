<#
    .SYNOPSIS
        Retrieves and sets environment variables for a specified PS.Severance environment.

    .DESCRIPTION
        This function loads environment variables from a JSON file located in the directory specified by the environment variable `PSSEnvRoot` and the provided environment name.
        It then sets each variable in the global scope of the current PowerShell session.
        The JSON file should be named `Environment_Variables.json` and contain key-value pairs representing the environment variables.

    .PARAMETER Environment
        The name of the PS.Severance environment for which to retrieve and set environment variables.
        This parameter is mandatory.
        Accepts a string representing the environment name.

    .EXAMPLE
        PS C:\> Get-PSSEnvVariables -Environment "Development"
        Loads and sets the environment variables for the "Development" environment.
#>
Function Get-PSSEnvVariables {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment
    )

    $EnvPath = "$ENV:PSSEnvRoot\$Environment"

    Try {
        # Load Json from file
        $EnvData = Get-Content -Path "$EnvPath\Environment_Variables.json" | ConvertFrom-Json
    }
    Catch {
        Throw "Failed to load environment variables from $EnvPath\Environment_Variables.json: $_"
    }

    # Foreach variable, set it in the session
    foreach ($key in $EnvData.PSObject.Properties.Name) {
        Try {
            Set-Variable -Name $key -Value $EnvData.$key -Scope Global
        }
        Catch {
            Write-Warning "Failed to set environment variable '$key': $_"
            
        }
    }
}