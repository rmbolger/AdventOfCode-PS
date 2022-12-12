#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d12.txt'
)

# https://adventofcode.com/2022/day/12

# Adapted from 2021's solution for Day 15

# Both Part 1 and 2 can be solved with a breadth-first search (Dijkstra)
# implementation. The implementations are almost identical if you start
# from the end instead of the beginning. The only difference is that the
# "end" condition in part 1 is a specific coordinate, while in part 2
# it's any 'a' coordinate including 'S'.
# https://en.wikipedia.org/wiki/Breadth-first_search
#
# There are no weights to any of the paths, so the "least cost" path is
# also the shortest path and distance equals the total number of steps.

# read the input and find our bounds
$lines = Get-Content $InputFile
$maxX = $lines[0].Length - 1
$maxY = $lines.Count - 1

# init the neighbor deltas
$nbrDeltas = '[[-1,0],[0,-1],[0,1],[1,0]]' | ConvertFrom-Json

function Invoke-PathSearch {
    param([switch]$Part2)

    # Store the coord map in a Dictionary with coord keys
    # and a hashtable value that contains height, distance
    # (steps) from the start, and neighbors we can climb
    # from. Distance starts as "infinity" for everything but
    # the start coord.
    $map = [Collections.Generic.Dictionary[string,hashtable]]::new()
    $null = $map.EnsureCapacity(($maxX+1)*($maxY+1))

    # load the map
    for ($y=0; $y -lt $lines.Count; $y++) {
        for ($x=0; $x -lt $lines[0].Length; $x++) {
            # make the coord key
            $key = "$x,$y"
            # 'E' is always start and 'S' is only the end for Part 1
            $height = $lines[$y][$x]
            if ($height -ceq 'E') {
                $height = [char]'z'
                $startKey = $key
            }
            elseif ($height -ceq 'S') {
                $height = [char]'z'
                $endKey = $key
            }
            # get the neighbors we can have climbed from
            $nbrs = foreach ($d in $nbrDeltas) {
                $nx = $x + $d[0]
                $ny = $y + $d[1]
                # ignore OOB neighbors
                if ($nx -lt 0 -or $maxX -lt $nx -or
                    $ny -lt 0 -or $maxY -lt $ny
                ) { continue }
                # only add neighbors 1 or less lower
                $nh = $lines[$ny][$nx]
                if ($nh -ceq 'S') { $nh = [char]'a' }
                elseif ($nh -ceq 'E') { $nh = [char]'z' }
                $diff = $height - $nh
                if ($diff -le 1) {
                    "$nx,$ny"
                }
            }
            # add the hashtable to the map
            $map[$key] = @{
                key = $key
                height = $height
                nbrs = $nbrs
                dist = [int]::MaxValue
            }
        }
    }

    # create a PriorityQueue with our starting vertex
    $pq = [Collections.Generic.PriorityQueue[PSObject,int]]::new()
    $start = $map[$startKey]
    $start.dist = 0
    $pq.Enqueue($start, $start.dist)

    # keep track of seen keys
    $seen = @{}

    while ($pq.Count -gt 0) {
        # grab the vertex with the next shortest distance
        $u = $pq.Dequeue()
        #Write-Verbose "checking $($u.key)"

        # check if we're done
        if ((-not $Part2 -and $u.key -eq $endKey) -or
            ($Part2 -and $u.height -eq 'a')
        ) {
            #Write-Verbose "END"
            $u.dist
            break
        }

        # skip if we've seen it already
        if ($seen.ContainsKey($u.key)) {
            #Write-Verbose "    already seen $($u.key)"
            continue
        }
        $seen[$u.key] = 1

        # loop through the neighbors
        foreach ($vKey in $u.nbrs) {
            $v = $map[$vKey]
            $newDist = $u.dist + 1
            if ($newDist -lt $v.dist) {
                $v.dist = $newDist
                $pq.Enqueue($v, $v.dist)
                #Write-Verbose "    queued $($v.key) with dist $($v.dist)"
            }
        }
    }
}

# Part 1
Invoke-PathSearch

# Part 2
Invoke-PathSearch -Part2
