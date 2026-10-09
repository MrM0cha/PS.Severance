<#
    .SYNOPSIS
        Registers argument completers for the 'Environment' parameter in various PS.Severance functions.

    .DESCRIPTION
        This script registers argument completers for the 'Environment' parameter in the defined functions.
        The completer suggests directories under the path specified by the environment variable `PSSEnvRoot`.
#>

# Argument completers for Customer parameter in New-Console and New-VSCodeWorkSpaceSession functions
Register-ArgumentCompleter -CommandName 'New-PSSConsole','New-PSSVSCodeWorkSpaceSession','New-PSSEnvironmentVariables','Update-PSSEnvironmentVariables','Get-PSSEnvironmentVariables','Install-PSSCustomModule' -ParameterName 'Environment' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # List of suggestions
    ((Get-ChildItem -Directory $ENV:PSSEnvRoot).Name) | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
