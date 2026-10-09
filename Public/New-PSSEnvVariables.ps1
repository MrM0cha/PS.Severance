<#
    .SYNOPSIS
        Creates environment variables for a specified environment.
    
    .DESCRIPTION
        This function creates a JSON file containing environment variables for the specified environment.
        If the UseCustomModuleVersions switch is specified, it also creates a CustomModules folder within the environment directory.
        The JSON file is saved in the environment's root folder as "Environment_Variables.json".
        This allows other scripts and tools to easily access the environment-specific configuration.

    .PARAMETER Environment
        The name of the environment.

    .PARAMETER TenantId
        The tenant ID for the environment.

    .PARAMETER Organisation
        The organisation for the environment.

    .PARAMETER UseCustomModuleVersions
        Switch indicating whether to set up custom module versions for the environment.
    
    .EXAMPLE
        PS C:\> New-PSSEnvVariables -Environment "Development" -TenantId "your-tenant-id" -Organisation "your-organisation" -UseCustomModuleVersions
        Creates a new "Development" environment variables file with the specified tenant ID and organisation. Custom module versions will also be set up if the switch is specified.

#>
Function New-PSSEnvVariables {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $true)]
        $TenantId,
        [Parameter(Mandatory = $true)]
        $Organisation,
        [Parameter(Mandatory = $false)]
        [boolean]$UseCustomModuleVersions = $false
    )
    $EnvPath = "$ENV:PSSEnvRoot\$Environment"

    # Build Json and save to file
    Try {
        $EnvData = @{
            TenantId     = $TenantId
            Organisation = "$("$Organisation" -replace '.onmicrosoft.com').onmicrosoft.com"
            UseCustomModuleVersions = $UseCustomModuleVersions
        }
        $EnvData | ConvertTo-Json | Out-File -FilePath "$EnvPath\Environment_Variables.json" -Encoding UTF8
        if ($UseCustomModuleVersions) {
            New-Item -Path "$EnvPath\CustomModules" -ItemType Directory | Out-Null
        }
        Write-Host "Environment variables file created at $EnvPath\Environment_Variables.json" -ForegroundColor Green
    }
    Catch {
        Write-Warning "Failed to create environment variables file at $($EnvPath)\Environment_Variables.json: $_"
    }
}
