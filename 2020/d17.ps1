[CmdletBinding()]
param(
    [string]$InputFile = '.\d17.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    # Function to get the active neighbor count for an encoded coordinate.
    function Get-ActiveNeighborCount {
        [CmdletBinding()]
        param(
            [int]$cVal,
            [hashtable]$g
        )
        $nei = Get-Neighbors $cVal
        $g.Keys | ?{ $_ -in $nei } | ForEach-Object -Begin {
            $active = 0
        } -Process {
            $active += $g.$_
        }
        $active
    }

    # Function to "run" a cycle
    function Invoke-Cycle {
        [CmdletBinding()]
        param([hashtable]$g)

        # clone the grid so we can modify it while we
        # process the original state
        $gNew = $g.Clone()
        Write-Verbose "$($g.Count) active points"

        $allNeighbors = $g.Keys | ForEach-Object {
            Get-Neighbors $_
        }
        Write-Verbose "$($allNeighbors.Count) total neighbors"
        $pointsToCheck = $allNeighbors + $g.Keys | Select-Object -unique
        Write-Verbose "$($pointsToCheck.Count) unique points to check"

        $pointsToCheck | ForEach-Object {
            $nc = Get-ActiveNeighborCount $_ $g
            #Write-Verbose "$((IntToCoord $cVal) -join ',') has $nc active neighbors"
            if ($g.$_ -and $nc -notin 2,3) {
                # go inactive
                $gNew.Remove($_)
            }
            elseif (-not $g.$_ -and $nc -eq 3) {
                # go active
                $gNew.$_ = 1
            }
        }

        # return the updated grid
        $gNew
    }



# Part 1
if (-not $NoPart1) {

    # From our initial 8x8x1 starting area, the most the volume can grow with
    # active cubes in 6 cycles is 20x20x13. Instead of tracking coordinates in
    # a 3d array, we're going to try encoding them into a single integer where
    # the first 5 bits = z, second 5 bits = y, third 5 bits = x. 5 bits for each
    # axis would allow for volume up to 31x31x31 so we should be good. We'll
    # represent the grid as a simple hashtable with encoded coordinate keys
    # and values = 1 for active cubes.

    # Functions to encode x,y,z to an int and back
    function CoordToInt {
        param([int]$x,[int]$y,[int]$z)
        $x -shl 10 -bor $y -shl 5 -bor $z
    }
    function IntToCoord {
        param([int]$cVal)
        $x = $cVal -shr 10 -band 31
        $y = $cVal -shr 5 -band 31
        $z = $cVal -band 31
        $x,$y,$z
    }

    $nCache = @{}

    # Function that will return the list of encoded
    # coordinates that make up a given coordinate's neighbors.
    function Get-Neighbors {
        [CmdletBinding()]
        param([int]$cVal)

        $cachedResult = $nCache[$cVal]
        if (-not $cachedResult) {
            [int]$x,[int]$y,[int]$z = IntToCoord $cVal

            $cachedResult = foreach ($dx in -1..1) {
                foreach ($dy in -1..1) {
                    foreach ($dz in -1..1) {
                        if ($dx -eq 0 -and
                            $dy -eq 0 -and
                            $dz -eq 0)
                        { continue }
                        CoordToInt ($x+$dx) ($y+$dy) ($z+$dz)
                    }
                }
            }

            $nCache[$cVal] = $cachedResult
        }
        return $cachedResult
    }

    # Load the active points from our input data into our grid hashtable.
    # Since our coordinate encoding scheme only works if the coords stay
    # positive, we need the first point to start at at least 6,6,6 because
    # will run for 6 cycles.
    $x = $y = $z = 6
    $grid = @{}
    Get-Content $InputFile | ForEach-Object {
        $_.ToCharArray() | ForEach-Object {
            if ($_ -eq '#') {
                # encode the coordinate and save it as active
                $grid[(CoordToInt $x $y $z)] = 1
            }
            $x++
        }
        $x = 6
        $y++
    }

    1..6 | %{
        Write-Verbose "Cycle $_"
        $grid = Invoke-Cycle $grid
    }

    Write-Host $grid.Count

}


# Part 2
if (-not $NoPart2) {

    # From our initial 8x8x1x1 starting area, the most the volume can grow with
    # active cubes in 6 cycles is 20x20x13x13. Instead of tracking coordinates
    # in a 4d array, we're going to encode them into a single integer where
    # each axis value is a 5 bit chunk of the integer. z = 0-4, y = 5-9,
    # x = 10-14, w = 15-19. 5 bits for each axis would allow for volume up
    # to 31x31x31x31. We'll represent the grid as a simple hashtable with
    # encoded coordinate keys and values = 1 for active hypercubes.

    # Create functions to encode w,x,y,z to an int and back
    function CoordToInt {
        param([int]$w,[int]$x,[int]$y,[int]$z)
        $w -shl 15 -bor $x -shl 10 -bor $y -shl 5 -bor $z
    }
    function IntToCoord {
        param([int]$cVal)
        $w = $cVal -shr 15 -band 31
        $x = $cVal -shr 10 -band 31
        $y = $cVal -shr 5 -band 31
        $z = $cVal -band 31
        $w,$x,$y,$z
    }

    # Create a function that will return the list of encoded
    # coordinates that make up a given coordinate's neighbors.
    $nCache = @{}

    function Get-Neighbors {
        [CmdletBinding()]
        param([int]$cVal)

        $cachedResult = $nCache[$cVal]
        if (-not $cachedResult) {
            [int]$w,[int]$x,[int]$y,[int]$z = IntToCoord $cVal

            $cachedResult = foreach ($dw in -1..1) {
                foreach ($dx in -1..1) {
                    foreach ($dy in -1..1) {
                        foreach ($dz in -1..1) {
                            if ($dw -eq 0 -and
                                $dx -eq 0 -and
                                $dy -eq 0 -and
                                $dz -eq 0)
                            { continue }
                            CoordToInt ($w+$dw) ($x+$dx) ($y+$dy) ($z+$dz)
                        }
                    }
                }
            }

            $nCache[$cVal] = $cachedResult
        }
        return $cachedResult
    }

    # Or coordinate encoding scheme only works if the coordss stay positive.
    # In order to keep our coordinates positive for 6 cycles, the first point
    # in the input data should start at 6,6,6,6.
    $w = $x = $y = $z = 6
    $grid = @{}
    Get-Content $InputFile | ForEach-Object {
        $_.ToCharArray() | ForEach-Object {
            if ($_ -eq '#') {
                # encode the coordinate and save it as active
                $grid[(CoordToInt $w $x $y $z)] = 1
            }
            $w++
        }
        $w = 6
        $x++
    }

    # In each cycle, the grid we need to check expands outwards by 1 in
    # in all directions.
    1..6 | %{
        Write-Verbose "Cycle $_"
        $grid = Invoke-Cycle $grid
    }

    Write-Host $grid.Count

}
