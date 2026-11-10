<#
    .SYNOPSIS
        Removes a specified PS.Severance environment.
    .DESCRIPTION
        This function allows you to remove an existing PS.Severance environment, including its associated environment variables and configurations.
    .PARAMETER Environment
        The name of the PS.Severance environment to remove.
        This parameter is mandatory and should be provided when calling the function.
    .EXAMPLE
        PS C:\> Remove-PSSEnvironment -Environment "Development"
        This example removes the "Development" PS.Severance environment.
#>
Function Remove-PSSEnvironment {
    [cmdletbinding(supportsshouldprocess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Environment
    )
    if ($PSCmdlet.ShouldProcess("Environment '$Environment'", "Remove")) {
        $envPath = Join-Path -Path $env:PSSEnvRoot -ChildPath $Environment
        if (Test-Path -Path $envPath) {
            Remove-Item -Path $envPath -Recurse -Force
        }
    }
}