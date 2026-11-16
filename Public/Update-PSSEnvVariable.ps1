<#
    .SYNOPSIS
        Updates environment variables for a specified environment.

    .DESCRIPTION
        This function updates the environment variables stored in the Environment_Variables.json file
        for the specified environment. It allows updating the TenantId, Organization, custom variables,
        and custom module versions.

    .PARAMETER Environment
        The name of the environment for which to update the variables.

    .PARAMETER TenantId
        The new TenantId value to set for the environment.

    .PARAMETER Organization
        The new Organization value to set for the environment.

    .PARAMETER CustomVariableName
        The name of the custom variable to update.

    .PARAMETER CustomVariableValue
        The value of the custom variable to update.

    .PARAMETER UseCustomModuleVersions
        Indicates whether to use custom module versions for the environment.

    .EXAMPLE
        PS C:\> Update-PSSEnvVariable -Environment "Development" -TenantId "new-tenant-id" -Organization "new-org"
        Updates the environment variables for the "Development" environment with the specified TenantId and Organization.

    .EXAMPLE
        PS C:\> Update-PSSEnvVariable -Environment "Development" -CustomVariableName "MyVar" -CustomVariableValue "MyValue"
        Updates the environment variables for the "Development" environment with the specified custom variable and value.

    .EXAMPLE
        PS C:\> Update-PSSEnvVariable -Environment "Development" -UseCustomModuleVersions $true
        Updates the environment variables for the "Development" environment to use custom module versions.
#>
Function Update-PSSEnvVariable {
    [cmdletbinding(supportsshouldprocess=$true)]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $false)]
        [string]$ColorCode,
        [Parameter(Mandatory = $false)]
        [string]$TenantId,
        [Parameter(Mandatory = $false)]
        [string]$Organization,
        [Parameter(Mandatory = $false)]
        [string]$CustomVariableName,
        [Parameter(Mandatory = $false)]
        [string]$CustomVariableValue,
        [Parameter(Mandatory = $false)]
        [switch]$UseCustomModuleVersions
    )

    $EnvPath = "$ENV:PSSEnvRoot\$Environment"

    # Load existing customer variables
    Try {
        if (-not (Test-Path -LiteralPath $EnvPath)) {
            Throw "Environment path not found for environment $($Environment)."
        }
        If (-not (Test-Path -LiteralPath "$EnvPath\Environment_Variables.json")) {
            Write-Debug "Environment variables file not found for environment $($Environment). Creating a new one."
            $NoFiles = $true
            $EnvData = @{}
        }
        Else {
            $EnvData = Get-Content -Path "$EnvPath\Environment_Variables.json" | ConvertFrom-Json
        }
    }
    Catch {
        throw "Failed to load environment variables for environment $($Environment): $_"
    }

    # Update variables if new values are provided
    Try {
        if ($ColorCode) {
            if ($EnvData.PSObject.Properties['ColorCode']) {
                $EnvData.ColorCode = $ColorCode
            } else {
                $EnvData | Add-Member -MemberType NoteProperty -Name ColorCode -Value $ColorCode
            }
        }
        if ($TenantId) {
            if ($EnvData.TenantId) {
                $EnvData.TenantId = $TenantId
            } else {
                    $EnvData | Add-Member -MemberType NoteProperty -Name TenantId -Value $TenantId
            }
        }
        if ($Organization) {
            if ($EnvData.Organization) {
                $EnvData.Organization = "$("$Organization" -replace '.onmicrosoft.com').onmicrosoft.com"
            } else {
                    $EnvData | Add-Member -MemberType NoteProperty -Name Organization -Value "$("$Organization" -replace '.onmicrosoft.com').onmicrosoft.com"
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
            if ($EnvData.PSObject.Properties['UseCustomModuleVersions']) {
                $EnvData.UseCustomModuleVersions = "true"
            } else {
                $EnvData | Add-Member -MemberType NoteProperty -Name UseCustomModuleVersions -Value "true"
                if (-not (Test-Path "$EnvPath\CustomModules")) {
                    New-Item -Path "$EnvPath\CustomModules" -ItemType Directory | Out-Null
                }
            }
        }
        elseif ($UseCustomModuleVersions -eq $false) {
            if ($EnvData.PSObject.Properties['UseCustomModuleVersions']) {
                $EnvData.UseCustomModuleVersions = "false"
            } else {
                $EnvData | Add-Member -MemberType NoteProperty -Name UseCustomModuleVersions -Value "false"
            }
        }

        If ($NoFiles) {
            If ($colorCode) {
                New-PSSEnvironment -Name $Environment -ColorCode $ColorCode -InitializeOnly
            }
            Else {
                New-PSSEnvironment -Name $Environment -InitializeOnly
            }
        }
        # Save updated customer variables back to file
        $EnvData | ConvertTo-Json | Out-File -FilePath "$EnvPath\Environment_Variables.json" -Encoding UTF8
    }
    Catch {
        throw "Failed to update environment variables for environment $($Environment): $_"
    }
}