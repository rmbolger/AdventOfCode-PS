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

    # Function that will return the list of encoded
    # coordinates that make up a given coordinate's neighbors.
    function Get-Neighbors {
        [CmdletBinding()]
        param([int]$cVal)
        # there might be a more clever/efficient way to do these deltas
        # with bit math, but we'll deal with that if it's a problem later
        $x,$y,$z = IntToCoord $cVal

        foreach ($dx in -1..1) {
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
    }

    # Function to "run" a cycle given a range for each axis to check
    function Invoke-Cycle {
        [CmdletBinding()]
        param(
            [hashtable]$g,
            [int[]]$xRange,
            [int[]]$yRange,
            [int[]]$zRange
        )

        # clone the grid so we can modify it while we
        # process the original state
        $gNew = $g.Clone()

        foreach ($x in $xRange) {
            foreach ($y in $yRange) {
                foreach ($z in $zRange) {
                    $cVal = CoordToInt $x $y $z
                    $nc = Get-ActiveNeighborCount $cVal $g
                    #Write-Verbose "$((IntToCoord $cVal) -join ',') has $nc active neighbors"
                    if ($g.$cVal -and $nc -notin 2,3) {
                        # go inactive
                        $gNew.Remove($cVal)
                    }
                    elseif (-not $g.$cVal -and $nc -eq 3) {
                        # go active
                        $gNew.$cVal = 1
                    }
                }
            }
        }

        # return the updated grid
        $gNew
    }

    # Load the active points from our input data into our grid hashtable.
    # Since our coordinate encoding scheme only works if the coords stay
    # positive, we need the first point to start at at least 6,6,6 because
    # will run for 6 cycles.
    $x = $y = $z = 6
    $grid = @{}
    Get-Content $InputFile | ForEach-Object {
        $startWidth = $_.Length
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

    # In each cycle, the grid we need to check expands outwards by 1 in
    # in all directions.
    $xs = $ys = $zs = $ze = 6
    $xe = $ye = 6 + $startWidth - 1
    for ($cycle=1; $cycle -le 6; $cycle++) {
        Write-Verbose "Cycle $cycle"
        # calc the axes ranges to check
        $xr = ($xs - $cycle)..($xe + $cycle)
        $yr = ($ys - $cycle)..($ye + $cycle)
        $zr = ($zs - $cycle)..($ze + $cycle)

        $grid = Invoke-Cycle $grid $xr $yr $zr
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
    function Get-Neighbors {
        [CmdletBinding()]
        param([int]$cVal)
        # there might be a more clever/efficient way to do these deltas
        # with bit math, but we'll deal with that if it's a problem later
        $w,$x,$y,$z = IntToCoord $cVal

        foreach ($dw in -1..1) {
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
    }


    function Invoke-Cycle {
        [CmdletBinding()]
        param(
            [hashtable]$g,
            [int[]]$wRange,
            [int[]]$xRange,
            [int[]]$yRange,
            [int[]]$zRange
        )

        # clone the grid so we can modify it while we
        # process the original state
        $gNew = $g.Clone()

        foreach ($w in $wRange) {
            foreach ($x in $xRange) {
                foreach ($y in $yRange) {
                    foreach ($z in $zRange) {
                        $cVal = CoordToInt $w $x $y $z
                        $nc = Get-ActiveNeighborCount $cVal $g
                        #Write-Verbose "$((IntToCoord $cVal) -join ',') has $nc active neighbors"
                        if ($g.$cVal -and $nc -notin 2,3) {
                            # go inactive
                            $gNew.Remove($cVal)
                        }
                        elseif (-not $g.$cVal -and $nc -eq 3) {
                            # go active
                            $gNew.$cVal = 1
                        }
                    }
                }
            }
        }

        # return the updated grid
        $gNew
    }

    # Or coordinate encoding scheme only works if the coordss stay positive.
    # In order to keep our coordinates positive for 6 cycles, the first point
    # in the input data should start at 6,6,6,6.
    $w = $x = $y = $z = 6
    $grid = @{}
    Get-Content $InputFile | ForEach-Object {
        $startWidth = $_.Length
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
    $ws = $xs = $ys = $ye = $zs = $ze = 6
    $we = $xe = 6 + $startWidth - 1
    for ($cycle=1; $cycle -le 6; $cycle++) {
        Write-Verbose "Cycle $cycle"
        # calc the axes ranges to check
        $wr = ($ws - $cycle)..($we + $cycle)
        $xr = ($xs - $cycle)..($xe + $cycle)
        $yr = ($ys - $cycle)..($ye + $cycle)
        $zr = ($zs - $cycle)..($ze + $cycle)

        $grid = Invoke-Cycle $grid $wr $xr $yr $zr
    }

    Write-Host $grid.Count

}
