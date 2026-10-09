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
    if ($ENV:PssWelcomeAscii) {
        $ascii = "█▀▀▄ ▄▀▀▀   ▄▀▀▀     ▀▄","█▀▀   ▀▀▄    ▀▀▄      ▄▀","▀    ▀▀▀  ▀ ▀▀▀      ▀   ▀▀▀▀"
        
        Try {
            $pswin = (Get-Host).UI.RawUI
            $pswinW = $pswin.WindowSize.Width
            $pswin.WindowTitle = "PS.S >_"


            cls
            foreach ($line in $ascii) {
                Write-Host (" "*(($pswinW/2)-15)) $line -ForegroundColor DarkGray
            }
            1..4 | foreach {Write-Output ""}
        }
        Catch {
            throw "Failed to display PS.Severance welcome message: $_"
        }
    }
}