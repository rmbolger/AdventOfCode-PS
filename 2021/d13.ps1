#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d13.txt'
)

# https://adventofcode.com/2021/day/13

$data = Get-Content $InputFile -Raw
Set-Clipboard $data

    $dotsRaw,$foldsRaw = (Get-Clipboard -Raw) -split "`n`n"

    $dots = $dotsRaw.Trim() -split "`n" | ForEach-Object {
        [int]$x,[int]$y = $_ -split ','
        [pscustomobject]@{
            x=$x
            y=$y
        }
    }

    $foldsRaw.Trim() -split "`n" | ForEach-Object {
        $foldCount += 1
        $axis,[int]$val = $_ -split '='
        $axis = [string]$axis[-1]

        for ($i=0; $i -lt $dots.Count; $i++) {
            $dot = $dots[$i]
            if ($dot.$axis -gt $val) {
                #Write-Verbose "$($axis) = 2*$val - $($dots[$i].$axis) = $(2*$val-$dots[$i].$axis)"
                $dot.$axis = 2*$val - $dot.$axis
            }
        }

        # get rid of dupes
        $dots = $dots | Sort-Object x,y -Unique

        # Part 1 - Count dots in the first fold
        if ($foldCount -eq 1) {
            Write-Host "Part 1: $(($dots = $dots | Sort-Object x,y -Unique).Count)"
        }
    }

    # find the size of our final paper
    $dots | ForEach-Object {
        $maxX = [Math]::Max($_.x,$maxX)
        $maxY = [Math]::Max($_.y,$maxY)
    }

    Write-Host "Part 2`n"
    $grid = 0..$maxY | %{ ,([string[]]((' '*($maxX+1)).ToCharArray())) }
    foreach ($dot in $dots) {
        $grid[$dot.y][$dot.x] = '█'
    }
    foreach ($line in $grid) {
        Write-Host ($line -join '')
    }
    Write-Host
