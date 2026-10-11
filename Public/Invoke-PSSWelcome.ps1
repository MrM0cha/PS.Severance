<#
    .SYNOPSIS
        Displays the PS.Severance welcome message with ASCII art.

    .DESCRIPTION
        This function checks if the PssWelcomeAscii environment variable is set to $True.
        If it is, it displays a welcome message with ASCII art in the PowerShell console.
        The function adjusts the positioning of the ASCII art based on the console window width.
        If an error occurs while displaying the message, an exception is thrown.

    .EXAMPLE
        PS C:\> Invoke-PssWelcome
        Displays the PS.Severance welcome message with ASCII art if the PssWelcomeAscii environment variable is set to $True.
#>
Function Invoke-PssWelcome {

    Try {
        $pswin = (Get-Host).UI.RawUI
        $pswinW = $pswin.WindowSize.Width
        $pswin.WindowTitle = "PS.S >_"

        Clear-Host
        $WelcomeReturn = New-Object System.Collections.ArrayList
        $ascii = "█▀▀▄ ▄▀▀▀   ▄▀▀▀     ▀▄","█▀▀   ▀▀▄    ▀▀▄      ▄▀","▀    ▀▀▀  ▀ ▀▀▀      ▀   ▀▀▀▀"
        foreach ($line in $ascii) {
            $LineOut = ((" "*(($pswinW/2)-15)) + $line)
            [Void]$WelcomeReturn.Add($LineOut)
        }
        1..4 | Foreach-Object { [Void]$WelcomeReturn.Add("") }

    }
    Catch {
        throw "Failed to display PS.Severance welcome message: $_"
    }

    $WelcomeReturn | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
}