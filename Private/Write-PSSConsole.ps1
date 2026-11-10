<#
    .SYNOPSIS
        Writes a message to the console with a specified foreground color.

    .DESCRIPTION
        This function allows you to write a message to the console with a specified foreground color.
        If no message is provided, it will output the input from the pipeline.

    .PARAMETER Message
        The message to write to the console.

    .PARAMETER ForegroundColor
        The color to use for the message text.

    .EXAMPLE
        Write-PSSConsole -Message "Hello, World!" -ForegroundColor Green
        This will write "Hello, World!" to the console in green color.

    .EXAMPLE
        Write-PSSConsole "Error occurred!" -ForegroundColor Red
        This will write "Error occurred!" to the console in red color.

    .EXAMPLE
        "Pipeline input" | Write-PSSConsole -ForegroundColor Cyan
        This will write "Pipeline input" to the console in cyan color.
#>

Function Write-PSSConsole {
    param (

        [Parameter(Mandatory=$false)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [System.ConsoleColor]$ForegroundColor
    )

    # save the current color
    $fc = $host.UI.RawUI.ForegroundColor

    # set the new color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    # output
    if ($Message) {
        #Write-Output $Message
        $Host.UI.WriteLine($Message)
    }
    else {
        $input | Write-Output
    }

    # restore the original color
    $host.UI.RawUI.ForegroundColor = $fc
}