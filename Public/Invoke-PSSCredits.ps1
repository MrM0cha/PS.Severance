<#
    .SYNOPSIS
    Displays the credits for the PS.Severance module.

    .DESCRIPTION
    This function shows the logo and splash texts for the PS.Severance module, along with the author's information.

    .PARAMETER Lines
    Specifies the number of lines to display at the same time.

    .PARAMETER LineLength
    Specifies the length of each line.

    .PARAMETER CodeColor
    Specifies the color of the code text.

    .PARAMETER LogoColor
    Specifies the color of the logo.

    .PARAMETER LogoIndent
    Specifies the indentation of the logo.

    .EXAMPLE
    Invoke-PSSCredits -Lines 10 -LineLength 5 -CodeColor Blue -LogoColor White -LogoIndent 0
#>
function Invoke-PSSCredits {
    param (
        $Lines,
        $LineLength,
        [ValidateSet('Black','Blue','Cyan','DarkBlue','DarkCyan','DarkGray','DarkGreen','DarkMagenta','DarkRed','DarkYellow','Gray','Green','Magenta','Red','White','Yellow')]
        [string]$CodeColor,
        [ValidateSet('Black','Blue','Cyan','DarkBlue','DarkCyan','DarkGray','DarkGreen','DarkMagenta','DarkRed','DarkYellow','Gray','Green','Magenta','Red','White','Yellow')]
        [string]$LogoColor,
        [int]$LogoIndent
    )

    if ($CodeColor.Length -eq 0) {$CodeColor = "Blue"}
    if ($LogoColor.Length -eq 0) {$LogoColor = "White"}

    $pswin = (Get-Host).UI.RawUI
    $pswinW = ($pswin.WindowSize.Width)
    $pswinH = ($pswin.WindowSize.Height)-1
    
    Foreach ($line in (1..$pswinH)) {
        New-Variable -Name ("Line"+$line) -Value ""
    }
    Foreach ($line in (1..$pswinW)) {
        New-Variable -Name $line -Value 0
    }

    cls

    # Build, set up and write logo and texts
    $LogoData = Get-Content $PSScriptRoot\PSS.Logo -Encoding UTF8
    $Logo = $LogoData | select -Skip 1
    $LogoIndents = ($LogoData | select -First 1) -split ","

    if ($LogoIndent -eq 0) {$PsWinIndent = (($pswinW/2)-25)}
    else {$PsWinIndent = $LogoIndent}
    
    $DrawLogo = {
        foreach ($LogoLine in 0..(($LogoData).Count-2)) {
            $pswin.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (($PsWinIndent)+$LogoIndents[$LogoLine]) , ((([math]::truncate($pswinH/2))-10)+($LogoLine+1))

            Write-Host -ForegroundColor $LogoColor $Logo[$LogoLine]
        }
    }

    invoke-command -ScriptBlock $DrawLogo
    Write ""
    Write-Host -ForegroundColor Gray (" "*(($pswinW/2)-20)+"-----  Press any key to return  -----")
    $pswin.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ((($pswinW/2)-20)) , (([math]::truncate($pswinH-1)))
    Write-Host -ForegroundColor Gray "PS.Severance - Teemu (Mokka) Kettunen"

    While ($true) {

        # Determine the total number of lines allowed at the same time
        if ($lines -lt 0 -or $lines -gt $pswinW -or $null -eq $lines) {$lines = 0.9}
        $MaxLines = (5..($pswinW*$lines)) | Get-Random
        
        # Retrieving the number of current lines
        $LineCount = 0
        Foreach ($num in (1..$pswinW)) {
            $NumQuery = (Get-Variable -Name $num).Value 
            if ($NumQuery -ne 0) {$LineCount += 1}
        }

        # Add lines
        If ($LineCount -lt $MaxLines) {
            if ($LineLength -lt 0 -or $null -eq $LineLength) {$LineLength = 1}
            $MaxLineLength = $pswinH*$LineLength
            $LineTreshold = 0
            Foreach ($Line in (1..(1..$MaxLines | Get-Random))) {
                $LineTreshold += 1
                $StartPos = 1..$pswinW | Get-Random
                $QueryPos = (Get-Variable -Name $StartPos).Value
                if ($QueryPos -lt ($pswinH*0.2) -and $LineTreshold -le 5) {Set-Variable -Name $StartPos -Value (1..$MaxLineLength | Get-Random)}
            }
        }

        # Calculate the age of line variables
        Foreach ($num in (1..$pswinW)) {
            if ((Get-Variable -Name $num).Value -ge 1) {Set-Variable -Name $num -Value ((Get-Variable -Name $num).Value-1)}
        }

        # Assemble all the line nodes to construct the row
        $NewLine = ""
        Foreach ($num in (1..$pswinW)) {
            $NumVal = (Get-Variable -Name $num).Value
            if ($NumVal -ge 1) {
                $NumChar = (97..122 | %{[char]$_}),(1..9) | Get-Random
                [string]$NewLine += $NumChar
            } Else {[string]$NewLine += " "}
        }

        # Build, set up and write splash texts
        $Splashes = Get-Content $PSScriptRoot\splash.txt -Encoding UTF8
        $SplashTimer += 1
        if ($SplashTimer -ge (5..10 | get-random)) {
            $SplashIndex += 1
            $SelSplash = $Splashes[$SplashIndex]
            $RndPoint = 1..($pswinW-$SelSplash.Length) | Get-Random

            $StrStart = ([char[]]$newline | select -First $RndPoint) -join ""
            $StrEnd = ([char[]]$newline | select -Skip ($RndPoint+$SelSplash.Length)) -join ""

            [string]$NewLine = ($StrStart,$SelSplash,$StrEnd) -join ""

            $SplashTimer = 0
            if ($SplashIndex -ge ($Splashes.Count - 1)) {$SplashIndex = -1}
            
        }
        
        # Scroll down the line row
        Foreach ($line in ($pswinH..2)) {
            Set-Variable -Name ("Line"+$line) -Value (Get-Variable -Name ("Line"+($line-1))).Value
        }
        $line1 = $NewLine

        # Write all the line rows at once with all the splash texts
        $pswin.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0 , 0
        $screen = $null
        foreach ($line in (1..$pswinH)) {
            if ($null -ne $screen) {$screen = $screen+"`n"+(Get-Variable -Name ("Line"+$line)).Value}
            else {$screen =(Get-Variable -Name ("Line"+$line)).Value}
        }
        Write-Host -ForegroundColor $CodeColor $screen

        # Build, set up and write logo
        invoke-command -ScriptBlock $DrawLogo

        # Check if any buttons have been pressed
        if ([Console]::KeyAvailable){
                # If button was pressed, clear console and escape the loop
                $keyInfo = [Console]::ReadKey($true)

                cls
                break
        }
        Start-Sleep -Milliseconds 100
    }
}