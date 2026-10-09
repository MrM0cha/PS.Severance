<#
    .SYNOPSIS
        Installs a custom PowerShell module for a specified PS.Severance environment.

    .DESCRIPTION
        This function downloads a specified version of a PowerShell module from the PSGallery
        and installs it into the CustomModules directory of the specified PS.Severance environment.
        The function ensures that the module is installed in a location specific to the environment, avoiding conflicts with other environments.
        This helps maintain a clean and organized module structure for each environment.

    .PARAMETER Environment
        The name of the PS.Severance environment where the module should be installed.
        This parameter is mandatory.

    .PARAMETER Name
        The name of the PowerShell module to install.
        This parameter is mandatory.

    .PARAMETER RequiredVersion
        The required version of the PowerShell module to install.
        This parameter is mandatory.

    .EXAMPLE
        PS C:\> Install-PSSCustomModule -Environment "Development" -Name "MyModule" -RequiredVersion "1.0.0"
        Installs version 1.0.0 of the "MyModule" module into the CustomModules directory of the "Development" environment.
#>
Function Install-PSSCustomModule { 
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$RequiredVersion
    )

    # Get Module path and create if not found
    $EnvPath = "$ENV:PSSEnvRoot\$Environment"
    $CustomModulePath = "$EnvPath\CustomModules"
    Try {
        If (-not (Test-Path -Path $CustomModulePath)) {
            New-Item -Path $CustomModulePath -ItemType Directory | Out-Null
        }
    }
    Catch {
        throw "Failed to create CustomModules directory at $($CustomModulePath): $_"
    }

    # Download module from PSGallery
    Try {
        Find-Module -Name $Name -Repository PSGallery -RequiredVersion $RequiredVersion | Save-Module -Path $CustomModulePath
        Write-Output "Module $Name (version $RequiredVersion) installed to $CustomModulePath"
    }
    Catch {
        throw "Failed to install module $Name (version $RequiredVersion) to $($CustomModulePath): $_"
    }
}