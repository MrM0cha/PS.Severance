<#
    .SYNOPSIS
        Registers argument completers for the 'Environment' parameter in various PS.Severance functions.

    .DESCRIPTION
        This script registers argument completers for the 'Environment' parameter in the defined functions.
        The completer suggests directories under the path specified by the environment variable `PSSEnvRoot`.
#>
$pssEnvironmentCommands = @(
    'New-PSSConsole',
    'New-PSSVSCodeWorkSpaceSession',
    'New-PSSEnvironmentVariables',
    'Update-PSSEnvironmentVariables',
    'Get-PSSEnvironmentVariables',
    'Install-PSSCustomModule',
    'Get-PSSEnvironment',
    'Remove-PSSEnvironment'
)

Register-ArgumentCompleter -CommandName $pssEnvironmentCommands -ParameterName 'Environment' -ScriptBlock {
    # Arguments passed by position: commandName, parameterName, wordToComplete, commandAst, fakeBoundParameters
    $wordToComplete = ([string]$args[2]).Trim("'", '"')

    # Stop here if the environment root isn't set or doesn't exist
    if (-not $env:PSSEnvRoot -or -not (Test-Path -LiteralPath $env:PSSEnvRoot)) { return }

    Get-ChildItem -LiteralPath $env:PSSEnvRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object Name -like "$wordToComplete*" |
        Sort-Object Name |
        ForEach-Object {
            # Put quotes around names that contain spaces
            $completionText = if ($_.Name -match '\s') { "'$($_.Name)'" } else { $_.Name }
            [System.Management.Automation.CompletionResult]::new($completionText, $_.Name, 'ParameterValue', $_.Name)
        }
}