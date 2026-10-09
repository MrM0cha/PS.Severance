<#
    .SYNOPSIS
        Updates environment variables for a specified environment.

    .DESCRIPTION
        This function updates the environment variables stored in the Environment_Variables.json file
        for the specified environment. It allows updating the TenantId, Organisation, custom variables,
        and custom module versions.

    .PARAMETER Environment
        The name of the environment for which to update the variables.

    .PARAMETER TenantId
        The new TenantId value to set for the environment.

    .PARAMETER Organisation
        The new Organisation value to set for the environment.

    .PARAMETER CustomVariableName
        The name of the custom variable to update.

    .PARAMETER CustomVariableValue
        The value of the custom variable to update.

    .PARAMETER UseCustomModuleVersions
        Indicates whether to use custom module versions for the environment.
    
    .EXAMPLE
        PS C:\> Update-PSSEnvVariables -Environment "Development" -TenantId "new-tenant-id" -Organisation "new-org"
        Updates the environment variables for the "Development" environment with the specified TenantId and Organisation.

    .EXAMPLE
        PS C:\> Update-PSSEnvVariables -Environment "Development" -CustomVariableName "MyVar" -CustomVariableValue "MyValue"
        Updates the environment variables for the "Development" environment with the specified custom variable and value.

    .EXAMPLE
        PS C:\> Update-PSSEnvVariables -Environment "Development" -UseCustomModuleVersions $true
        Updates the environment variables for the "Development" environment to use custom module versions.
#>
Function Update-PSSEnvVariables {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $false)]
        $TenantId,
        [Parameter(Mandatory = $false)]
        $Organisation,
        [Parameter(Mandatory = $false)]
        $CustomVariableName,
        [Parameter(Mandatory = $false)]
        $CustomVariableValue,
        [Parameter(Mandatory = $false)]
        $UseCustomModuleVersions
    )

    $EnvPath = "$ENV:PSSEnvRoot\$Environment"

    # Load existing customer variables
    Try {
        $EnvData = Get-Content -Path "$EnvPath\Environment_Variables.json" | ConvertFrom-Json
    }
    Catch {
        throw "Failed to load environment variables for environment $($Environment): $_"
    }

    # Update variables if new values are provided
    Try {
        if ($TenantId) {
            if ($EnvData.TenantId) {
                $EnvData.TenantId = $TenantId
            } else {
                    $EnvData | Add-Member -MemberType NoteProperty -Name TenantId -Value $TenantId
            }
        }
        if ($Organisation) {
            if ($EnvData.Organisation) {
                $EnvData.Organisation = "$("$Organisation" -replace '.onmicrosoft.com').onmicrosoft.com"
            } else {
                    $EnvData | Add-Member -MemberType NoteProperty -Name Organisation -Value "$("$Organisation" -replace '.onmicrosoft.com').onmicrosoft.com"
            }
        }
        if ($CustomVariableName -and $CustomVariableValue) {
            if ($EnvData.PSObject.Properties[$CustomVariableName]) {
                $EnvData.$CustomVariableName = $CustomVariableValue
            } else {
                $EnvData | Add-Member -MemberType NoteProperty -Name $CustomVariableName -Value $CustomVariableValue
            }
        }
        if ($UseCustomModuleVersions) {
            if ($EnvData.PSObject.Properties['CustomModuleVersions']) {
                $EnvData.CustomModuleVersions = $UseCustomModuleVersions
            } else {
                $EnvData | Add-Member -MemberType NoteProperty -Name CustomModuleVersions -Value $UseCustomModuleVersions
                New-Item -Path "$EnvPath\CustomModules" -ItemType Directory | Out-Null
            }
        }

        # Save updated customer variables back to file
        $EnvData | ConvertTo-Json | Out-File -FilePath "$EnvPath\Environment_Variables.json" -Encoding UTF8
    }   
    Catch {
        throw "Failed to update environment variables for environment $($Environment): $_"
    }
}
