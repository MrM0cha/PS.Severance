<#
    .SYNOPSIS
        Removes a specified environment variable from the environment configuration.

    .PARAMETER Environment
        The name of the environment from which to remove the variable.

    .PARAMETER VariableName
        The name of the variable to remove.

    .EXAMPLE
        Remove-PSSEnvVariable -Environment "Dev" -VariableName "TenantId"
        This command removes the "TenantId" variable from the "Dev" environment.
#>
function Remove-PSSEnvVariable {
    [cmdletbinding(supportsshouldprocess=$true)]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $true)]
        [string]$VariableName
    )
    $EnvPath = "$ENV:PSSEnvRoot\$Environment"

    # Load existing customer variables
    Try {
        if (-not (Test-Path -LiteralPath $EnvPath)) {
            Throw "Environment path not found for environment $($Environment)."
        }
        If (-not (Test-Path -LiteralPath "$EnvPath\Environment_Variables.json")) {
            Throw "Environment variables file not found for environment $($Environment)."
        }
        $EnvData = Get-Content -Path "$EnvPath\Environment_Variables.json" | ConvertFrom-Json
    }
    Catch {
        throw "Failed to load environment variables for environment $($Environment): $_"
    }

    # Remove the specified variable if it exists
    Try {
        if ($EnvData.PSObject.Properties[$VariableName]) {
            $EnvData.PSObject.Properties.Remove($VariableName)
            $EnvData | ConvertTo-Json | Out-File -FilePath "$EnvPath\Environment_Variables.json" -Encoding UTF8
        } else {
            Write-Warning "Variable '$VariableName' not found in environment '$Environment'."
        }
    }
    Catch {
        throw "Failed to remove environment variable '$VariableName' from environment '$Environment': $_"
    }
}
