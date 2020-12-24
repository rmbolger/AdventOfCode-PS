[CmdletBinding()]
param(
    [string]$InputFile = '.\d24.txt',
    [switch]$NoPart2
)


# parse the input into discrete sets of directions per line
$reDir = [regex]'(?:(?:s|n)?(?:e|w))'
$tileDirs = Get-Content $InputFile | ForEach-Object {
    ,$reDir.Matches($_).Value
}

# using the cube-coordinate method for the hex coordinates
# https://www.redblobgames.com/grids/hexagons/

# define our coordinate deltas for each direction
$dirDeltas = @{
    ne = 1,0,-1
    e = 1,-1,0
    se = 0,-1,1
    sw = -1,0,1
    w = -1,1,0
    nw = 0,1,-1
}

# Part 1

    # follow each set of directions using our coordinate deltas
    $blackTiles = [Collections.Generic.HashSet[string]]::new()
    $tileDirs | ForEach-Object {
        $x = $y = $z = 0
        $_ | ForEach-Object {
            $dx,$dy,$dz = $dirDeltas[$_]
            $x += $dx
            $y += $dy
            $z += $dz
        }
        $coord = "$x,$y,$z"
        #Write-Verbose "coord $coord"
        if (-not $blackTiles.Add($coord)) {
            # add failed, so it's already there
            # so flip it white by removing it
            [void] $blackTiles.Remove($coord)
        }
    }
    Write-Host $blackTiles.Count


# Part 2
if (-not $NoPart2) {

    $neighborDeltas = "[[1,0,-1],[1,-1,0],[0,-1,1],[-1,0,1],[-1,1,0],[0,1,-1]]" | ConvertFrom-Json

    # function to get a list of neighbor coordinates
    # given a hex coordinate with a cache layer
    $neiCache = [Collections.Generic.Dictionary[string,Collections.Generic.HashSet[string]]]::new()
    function Get-Neighbors {
        [CmdletBinding()]
        param([string]$Coord)

        # return the cached list if it exists
        $hset = $neiCache[$Coord]
        if (-not $hset) {
            # calculate the list and add it to the cache
            # before returning it
            $x,$y,$z = [int[]]$Coord.Split(',')
            [string[]]$list = $neighborDeltas | ForEach-Object {
                $dx,$dy,$dz = $_
                "$($x+$dx),$($y+$dy),$($z+$dz)"
            }
            $hset = [Collections.Generic.HashSet[string]]::new($list)
            $neiCache[$Coord] = $hset
        }
        return ,$hset
    }

    function Invoke-Flip {
        [CmdletBinding()]
        param(
            [Collections.Generic.HashSet[string]]$BlackTiles
        )

        # get the list of white tiles to check in addition to the black
        # tiles which is basically the unique set of the black tile neighbors
        # that are not black tiles themselves
        $neiSets = $BlackTiles | ForEach-Object { Get-Neighbors $_ }
        $whiteTiles = [Collections.Generic.HashSet[string]]::new($neiSets[0])
        $neiSets | Select-Object -Skip 1 | ForEach-Object {
            $whiteTiles.UnionWith($_)
        }
        $whiteTiles.ExceptWith($BlackTiles)
        #Write-Verbose "black $($BlackTiles.Count) - white $($whiteTiles.Count)"

        # create a copy of the black tiles to manipulate
        $btNew = [Collections.Generic.HashSet[string]]::new($BlackTiles)

        # check black tiles
        foreach ($tile in $BlackTiles) {
            $nei = [Collections.Generic.HashSet[string]]::new((Get-Neighbors $tile))
            $nei.IntersectWith($BlackTiles)
            if ($nei.Count -eq 0 -or $nei.Count -gt 2) {
                #Write-Verbose "$($tile.PadRight(8)) : black -> white"
                [void] $btNew.Remove($tile)
            }
        }
        # check white tiles
        foreach ($tile in $whiteTiles) {
            $nei = [Collections.Generic.HashSet[string]]::new((Get-Neighbors $tile))
            $nei.IntersectWith($BlackTiles)
            if ($nei.Count -eq 2) {
                #Write-Verbose "$($tile.PadRight(8)) : white -> black"
                [void] $btNew.Add($tile)
            }
        }

        return $btNew
    }

    1..100 | ForEach-Object {
        $blackTiles = Invoke-Flip $blackTiles
        Write-Verbose "Day $_ - $($blackTiles.Count)"
    }
    Write-Host $blackTiles.Count

}
