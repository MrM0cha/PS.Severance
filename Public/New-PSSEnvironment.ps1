<#
    .SYNOPSIS
        Creates a new PS.Severance environment with the specified settings.

    .DESCRIPTION
        This function creates a new environment folder, optionally sets up custom module versions,
        and generates a VSCode settings file with the specified color customizations.
        It also checks for existing environment variables and creates them if they do not exist.
    
    .PARAMETER Name
        The name of the environment to create.

    .PARAMETER ColorCode
        The color code to use for the environment's VSCode settings. Use a hexadecimal color code (e.g., "#FF0000").

    .PARAMETER TenantId
        The tenant ID associated with the environment.

    .PARAMETER Organisation
        The organisation associated with the environment. No need to specify tenant suffix. It will be automatically appended if required.

    .PARAMETER UseCustomModuleVersions
        Switch indicating whether to set up custom module versions for the environment.

    .EXAMPLE
        PS C:\> New-PSSEnvironment -Name "Development" -ColorCode "#FF0000" -UseCustomModuleVersions
        Creates a new "Development" environment with the specified color code. Custom module versions will also be set up if the switch is specified.
    
    .EXAMPLE
        PS C:\> New-PSSEnvironment -Name "Development" -ColorCode "#FF0000" -TenantId "your-tenant-id" -Organisation "your-organisation"
        Creates a new "Development" environment with the specified color code, tenant ID, and organisation.
#>
Function New-PSSEnvironment {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$ColorCode,
        [Parameter(Mandatory = $false)]
        [string]$TenantId,
        [Parameter(Mandatory = $false)]
        [string]$Organisation,
        [Parameter(Mandatory = $false)]
        [switch]$UseCustomModuleVersions
    )

    $FolderPath = "$ENV:PSSEnvRoot\$Name"
    Try {
        If (-not (Test-Path $FolderPath)) {
            New-Item -Path $FolderPath -ItemType Directory | Out-Null
            Write-Host "Environment folder created at $FolderPath" -ForegroundColor Green
        } else {
            Write-Host "Environment folder already exists at $FolderPath" -ForegroundColor Yellow
        }
    }
    Catch {
        throw "Failed to create environment folder at $($FolderPath): $_"
    }

    if ($UseCustomModuleVersions) {
        Try {
            New-Item -Path "$FolderPath\CustomModules" -ItemType Directory | Out-Null
        }
        Catch {
            Write-Warning "Failed to create CustomModules folder at $($FolderPath): $_"
        }
    }

    $CodeProfilePath = "$ENV:PSSEnvRoot\$Name\.vscode\"
    Try {
        If (-not (Test-Path $CodeProfilePath)) {
            Write-Host "VSCode profile folder created at $CodeProfilePath" -ForegroundColor Green
            New-Item -Path $CodeProfilePath -ItemType Directory | Out-Null
        }
        
        $SettingsFilePath = "$ENV:PSSEnvRoot\$Name\.vscode\settings.json"
        If (-not (Test-Path $SettingsFilePath)) {
            $SettingsContent = @"
{
    "workbench.colorCustomizations": {
        "titleBar.activeBackground": "$ColorCode",
        "titleBar.activeForeground": "#000000",
        "titleBar.inactiveBackground": "$ColorCode",
        "titleBar.inactiveForeground": "#000000"
    }
}
"@
        $SettingsContent | Out-File -FilePath $SettingsFilePath -Encoding UTF8
        Write-Host "VSCode settings file created at $SettingsFilePath" -ForegroundColor Green
        } 
        else {
            Write-Host "VSCode settings file already exists at $SettingsFilePath" -ForegroundColor Yellow
        }
    }
    Catch {
        Write-Warning "Failed to create VSCode profile folder at $($CodeProfilePath): $_"
    }

    # Check if Environment Variables already exist
    $EnvDataPath = "$FolderPath\Environment_Variables.json"
    If (-not (Test-Path -Path $EnvDataPath)) {
        Try {
            New-PSSEnvVariables -Environment $Name -TenantId $TenantId -Organisation $Organisation -UseCustomModuleVersions $UseCustomModuleVersions
            Write-Host "Environment variables file created at $EnvDataPath" -ForegroundColor Green
        }
        Catch {
            Write-Warning "Failed to create environment variables file at $($EnvDataPath): $_"
        }
    } else {
        Write-Host "Environment variables file already exists at $EnvDataPath" -ForegroundColor Yellow
    }
}