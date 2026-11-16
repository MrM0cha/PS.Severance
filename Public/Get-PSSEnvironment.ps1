<#
    .SYNOPSIS
        Retrieves information about PS.Severance environments.

    .DESCRIPTION
        This function retrieves information about PS.Severance environments.
        If the 'Environment' parameter is specified, it retrieves details for that specific environment.
        If the 'Environment' parameter is not specified, it retrieves details for all environments.

    .PARAMETER Environment
        The name of the environment to retrieve. If not specified, all environments are retrieved.

    .EXAMPLE
        Get-PSSEnvironment -Environment "Dev"
        Retrieves information about the "Dev" environment.

    .EXAMPLE
        Get-PSSEnvironment
        Retrieves information about all environments.

    .EXAMPLE
        (Get-PSSEnvironment -Environment "Prod").Variables
        Retrieves the environment variables for the "Prod" environment.

    .EXAMPLE
        (Get-PSSEnvironment).Variables
        Retrieves the environment variables for all environments.
#>
Function Get-PSSEnvironment {
    Param (
    [Parameter(Mandatory=$false)]
    [string]$Environment
    )

    if ($Environment) {
        # Logic to get the environment by name
        $EnvPath = "$ENV:PSSEnvRoot\$Environment"
        $EnvName = $Environment

        $Environment = Get-Item -Path $EnvPath -ErrorAction SilentlyContinue
        if ($Environment) {
            $EnvVariables = Get-Content -Path "$EnvPath\Environment_Variables.json"

            $EnvData = [pscustomobject]@{
                Name = $EnvName
                Path = $EnvPath
                Variables = $EnvVariables | ConvertFrom-Json
            }
            return $EnvData
        }
        else {
            Write-Warning "Environment '$Environment' not found."
        }
    }
    else {
        # Logic to get all environments
        $Environments = Get-ChildItem -Path "$ENV:PSSEnvRoot" -Directory
        $EnvDataList = New-Object System.Collections.ArrayList
        foreach ($Env in $Environments) {
            $EnvPath = $Env.FullName
            $EnvName = $Env.Name
            $EnvVariables = Get-Content -Path "$EnvPath\Environment_Variables.json" -ErrorAction SilentlyContinue
            $EnvData = [pscustomobject]@{
                Name = $EnvName
                Path = $EnvPath
                Variables = $EnvVariables | ConvertFrom-Json
            }
            [void]$EnvDataList.Add($EnvData)
        }
        return $EnvDataList
    }
}