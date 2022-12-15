#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d14.txt',
    [switch]$Viz
)

# https://adventofcode.com/2022/day/14

# Get the bounds of our cave system and save the unique coords that
# make up all of the rock paths and the starting point. yMin will
# always be 0 because it's the source of the sand drop.
$xMin=$xMax=500
$yMax=0
[int[][]]$rockCoords = Get-Content $InputFile | ForEach-Object {
    # get the vertex coords that make up this path
    # and update bounds
    $path = $_ -split ' -> ' | ForEach-Object {
        $x,$y = [int[]]$_.Split(',')
        $xMin = [Math]::Min($x, $xMin)
        $xMax = [Math]::Max($x, $xMax)
        $yMax = [Math]::Max($y, $yMax)
        ,@($x,$y)
    }
    # loop through the path calculating the individual coords
    for ($i=1; $i -lt $path.Count; $i++) {
        $a = $path[$i-1]
        $b = $path[$i]
        foreach ($x in ($a[0]..$b[0])) {
            foreach ($y in ($a[1]..$b[1])) {
                ,@($x,$y)
            }
        }
    }
} | Sort-Object -Unique {$_[0]},{$_[1]}

function Invoke-Simulation {
    [CmdletBinding()]
    param(
        [switch]$Part2,
        [switch]$Viz
    )

    $air = [char]'.'
    $sand = [char]'o'
    $rock = [char]'#'

    # create 2D array the size of our bounds representing an empty cave
    if (-not $Part2) {
        $height = $yMax
        $widthMin = $xMin
        $widthMax = $xMax
        $width = $widthMax - $widthMin + 1
        [char[][]]$cave = 0..$height | ForEach-Object {
            ,($air.ToString() * $width).ToCharArray()
        }
    } else {
        # Include the floor which is yMax + 2
        $height = $yMax + 2
        # Set the width bounds so there's enough space for
        # the sand to come to rest at the drop source.
        $widthMin = 500 - $height - 1
        $widthMax = 500 + $height + 1
        $width = $widthMax - $widthMin + 1
        [char[][]]$cave = 0..$height | ForEach-Object {
            if ($_ -ne $height) {
                ,($air.ToString() * $width).ToCharArray()
            } else {
                ,($rock.ToString() * $width).ToCharArray()
            }
        }
    }
    $dropSrc = [int[]]@((500-$widthMin),0)

    # Normalize the rock x-coords to 0 based on our bounds and
    # update the cave with the them
    foreach ($c in $rockCoords) {
        $x = $c[0] - $widthMin
        $cave[$c[1]][$x] = $rock
    }

    function Test-OOB {
        param([int]$x,[int]$y)
        ($x -lt 0 -or $x -gt $widthMax -or $y -ge $height)
    }

    function VisualizeCave {
        foreach ($row in $cave) {
            Write-Host ($row -join '')
        }
    }

    # The sand drop function will simulate dropping a single piece of sand
    # in the current cave state.
    # Returns $true and the start coord of the next drop if the piece comes to rest
    # Returns $false if the piece falls into the abyss
    function New-SandDrop {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [int[]]$startAt
        )

        #Write-Verbose "starting at $($startAt -join ',')"
        $x = $startAt[0]
        for ($y=$startAt[1]; $y -lt $cave.Count; $y++) {

            # check if we're falling into the abyss
            if (Test-OOB $x $y) {
                Write-Verbose "$x,$y is OOB"
                return $false
            }

            $ny = $y+1

            # check down
            $nx = $x
            if ($cave[$ny][$nx] -eq $air) {
                $prevCache["$nx,$ny"] = [int[]]@($x,$y)
                #Write-Verbose "down free, prev is $x,$y"
                continue
            }

            # check down left
            $nx = $x-1
            if ($cave[$ny][$nx] -eq $air) {
                $prevCache["$nx,$ny"] = [int[]]@($x,$y)
                #Write-Verbose "down left free, prev is $x,$y"
                $x = $nx
                continue
            }

            # check down right
            $nx = $x+1
            if ($cave[$ny][$nx] -eq $air) {
                $prevCache["$nx,$ny"] = [int[]]@($x,$y)
                #Write-Verbose "down right free, prev is $x,$y"
                $x = $nx
                continue
            }

            # come to rest
            $cave[$y][$x] = $sand
            if ($x -eq $dropSrc[0] -and $y -eq $dropSrc[1]) {
                Write-Verbose "rest at source, all done"
                return $false
            } else {
                #Write-Verbose "rest, returning prev $($prevCache["$x,$y"]-join',')"
                return $true,$prevCache["$x,$y"]
            }
        }

        Write-Warning "should never get here"
        return $false
    }

    # As sand drops, keep track of the previous coord so the next piece
    # can start at the previous location instead of always simulating
    # from the drop source.
    $prevCache = [Collections.Generic.Dictionary[string,int[]]]::new()

    # run the sim until it stops
    $total = 0
    $dropStart = $dropSrc
    do {
        $dropNew,$dropStart = New-SandDrop $dropStart
        if ($dropNew) { $total++ }
    }
    while ($dropNew)

    if ($Viz) { VisualizeCave }

    ($Part2) ? ($total+1) : $total
}


# Part 1

Invoke-Simulation -Viz:$Viz.IsPresent

# Part 2

Invoke-Simulation -Part2 -Viz:$Viz.IsPresent
