#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d5.txt'
)

# https://adventofcode.com/2021/day/5

$data = Get-Content $InputFile
Set-Clipboard $data

function Get-Points {
    [CmdletBinding()]
    param(
        [object[]]$Coords
    )

    foreach ($c in $Coords) {
        Write-Verbose ($c -join ',')

        # enumerate the points between x1,y1 and x2,y2
        $x,$y = $c[0],$c[1]
        do {
            "$x,$y"
            # increment/decrement x and y if they're not already done
            if ($x -ne $c[2]) { $x += ($c[0] -le $c[2]) ? 1 : -1 }
            if ($y -ne $c[3]) { $y += ($c[1] -le $c[3]) ? 1 : -1 }
        }
        while ($x -ne $c[2] -or $y -ne $c[3])

        # don't forget the last point
        "$x,$y"
    }
}

# parse the input
$coords = gcb | %{
    ,[int[]](($_.Replace(' -> ',',')) -split ',')
}

# separate the diagonals and non-diagonals
$nonDiags = $coords | Where-Object {
    $_[0] -eq $_[2] -or $_[1] -eq $_[3]
}
$diags = $coords | Where-Object {
    $_[0] -ne $_[2] -and $_[1] -ne $_[3]
}

# Part 1

    $points = Get-Points $nonDiags
    ($points |
        Group-Object |
        Where-Object { $_.Count -gt 1 } |
        Measure-Object
    ).Count

# Part 2

    $points += Get-Points $diags
    ($points |
        Group-Object |
        Where-Object { $_.Count -gt 1 } |
        Measure-Object
    ).Count



    $board1 = [Collections.Generic.Dictionary[string, int]]::new() # board for part 1
    $board2 = [Collections.Generic.Dictionary[string, int]]::new() # board for part 2

    foreach ($line in (gcb)) {

        [int]$x1, [int]$y1, [int]$x2, [int]$y2 = $line -split ' -> ' -split ','

        if     ($x1 -eq $x2) { foreach ($y in $y1..$y2) { $board1["$x1, $y"] += 1; $board2["$x1, $y"] += 1 } } # vertical
        elseif ($y1 -eq $y2) { foreach ($x in $x1..$x2) { $board1["$x, $y1"] += 1; $board2["$x, $y1"] += 1 } } # horizontal

        else {                                                                                                 # diagonal
            if ($x1 -gt $x2) { $x1, $y1, $x2, $y2 = $x2, $y2, $x1, $y1  }           #swap pairs so X is always increasing

            $x,$y = $x1,$y1

            if ($y1 -lt $y2) { # case y increasing, up-right
                while ($x -le $x2) { # lines are always 45 degree, both should end at same time
                    $board2["$x, $y"] += 1
                    $x+=1
                    $y+=1
                }
            } else {           # case y decreasing, down-right
                while ($x -le $x2) {
                    $board2["$x, $y"] += 1
                    $x+=1
                    $y-=1
                }
            }
        }
    }

    write-host "Part 1"
    write-host ($board1.GetEnumerator().where{$_.value -gt 1} | measure |% count)
    write-host "Part 2"
    write-host ($board2.GetEnumerator().where{$_.value -gt 1} | measure |% count)
