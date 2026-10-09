<#
    .SYNOPSIS
        Retrieves the current PowerShell console title.

    .DESCRIPTION
        This script defines a class to interact with the Windows API to get the current console title.
        It then retrieves the console title and removes the prefix defined in the environment variable `PSSConPrefix`.

#>

# Get the current console title
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ConsoleTitle {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int GetConsoleTitle(System.Text.StringBuilder lpConsoleTitle, int nSize);
}
"@
$PssConsoleTitle = New-Object System.Text.StringBuilder 1024
[ConsoleTitle]::GetConsoleTitle($PssConsoleTitle, $PssConsoleTitle.Capacity) | Out-Null
$PssConsoleTitle = $PssConsoleTitle -replace $ENV:PSSConPrefix