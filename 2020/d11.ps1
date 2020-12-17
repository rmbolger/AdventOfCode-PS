[CmdletBinding()]
param(
    [string]$InputFile = '.\d11.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# create a list of x,y directional deltas for finding neighbors
$dirDeltas = '[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]' | ConvertFrom-Json

function Get-TotalOccupied {
    param(
        [char[][]]$g
    )
    $g | ForEach-Object -Begin {
        $count = 0
    } -Process {
        $count += ($_ | ?{ $_ -eq '#' }).Count
    }
    $count
}

function Invoke-FillSeats {
    param(
        [char[][]]$g,
        [int]$occMax,
        [string]$funcAdj
    )

    # clone the grid so we can modify it while we
    # process the original state
    [char[][]]$gnew = $g | %{ ,@($_.Clone()) }

    foreach ($y in (0..($g.Count-1))) {
        foreach ($x in (0..($g[0].Count-1))) {
            $occ = &$funcAdj $g $x $y
            if ($g[$y][$x] -eq 'L' -and $occ -eq 0) {
                $gnew[$y][$x] = '#'
            } elseif ($g[$y][$x] -eq '#' -and $occ -ge $occMax) {
                $gnew[$y][$x] = 'L'
            }
        }
    }

    # return the updated grid
    ,$gnew
}

function Show-Grid {
    param([char[][]]$g)
    clear
    $g | %{ $_ -join '' }
    Start-Sleep -Milliseconds 100
}


# Part 1
if (-not $NoPart1) {

    function Get-AdjOccupiedPart1 {
        param(
            [char[][]]$g,
            [int]$x,
            [int]$y
        )

        $xMax = $g[0].Count-1
        $yMax = $g.Count-1

        # how many adjacent spaces are occupied
        $occ = 0
        foreach ($d in $dirDeltas) {
            $xd = $x+$d[0]; $yd = $y+$d[1]
            if ($xd -lt 0 -or $xd -gt $xMax -or $yd -lt 0 -or $yd -gt $yMax) {
                # out of bounds
                continue
            }
            if ($g[$yd][$xd] -eq '#') {
                $occ++
            }
        }

        $occ
    }


    # build a 2D array of characters from the input
    [char[][]]$grid = Get-Content $InputFile | %{ ,@([char[]]$_) }

    $lastOccupied = -1
    while ($lastOccupied -ne ($occupied = (Get-TotalOccupied $grid))) {
        #Write-Verbose "$lastOccupied to $occupied"
        #Show-Grid $grid
        $lastOccupied = $occupied
        $grid = Invoke-FillSeats $grid 4 'Get-AdjOccupiedPart1'
    }
    $occupied

}


# Part 2
if (-not $NoPart2) {

    function Get-AdjOccupiedPart2 {
        param(
            [char[][]]$g,
            [int]$x,
            [int]$y
        )

        $xMax = $g[0].Count-1
        $yMax = $g.Count-1

        # how many seats are occupied in each direction
        $occ = 0
        :outer foreach ($d in $dirDeltas) {

            # find the first non-floor space in this direction
            $xd = $x; $yd = $y
            do {
                $xd += $d[0]; $yd += $d[1]
                if ($xd -lt 0 -or $xd -gt $xMax -or $yd -lt 0 -or $yd -gt $yMax) {
                    # out of bounds
                    continue outer
                }
            } while ($g[$yd][$xd] -eq '.') # floor space, keep going

            if ($g[$yd][$xd] -eq '#') {
                $occ++
            }
        }

        $occ
    }

    # build a 2D array of characters from the input
    [char[][]]$grid = Get-Content $InputFile | %{ ,@([char[]]$_) }

    $lastOccupied = -1
    while ($lastOccupied -ne ($occupied = (Get-TotalOccupied $grid))) {
        #Write-Verbose "$lastOccupied to $occupied"
        Show-Grid $grid
        $lastOccupied = $occupied
        $grid = Invoke-FillSeats $grid 5 'Get-AdjOccupiedPart2'
    }
    $occupied

}
