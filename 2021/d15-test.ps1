#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d15.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/15

$data = Get-Content $InputFile
Set-Clipboard $data

$lines = Get-Clipboard
if (-not $Part2) {
    $maxX = $lines[0].Length - 1
    $maxY = $lines.Count - 1
} else {
    $maxX = $lines[0].Length * 5 - 1
    $maxY = $lines.Count * 5 - 1
}

# basic 2D map of the input as integers
$grid = for ($y=0; $y -le $maxY; $y++) {
    ,[int[]]($lines[$y].ToCharArray() | %{ $_-48 })
}

# init the neighbor deltas
$nbrDeltas = '[[-1,0],[0,-1],[0,1],[1,0]]' | ConvertFrom-Json



<# Part2 expansion deltas for sample where puzzle is 10x10
 0, 0  10, 0  20, 0  30, 0  40, 0
 0,10  10,10  20,10  30,10  40,10
 0,20  10,20  20,20  30,20  40,20
 0,30  10,30  20,30  30,30  40,30
 0,40  10,40  20,40  30,40  40,40
#>
# build the expansion deltas for part 2
$expDeltas = for ($y=0; $y -lt 5; $y++) {
    for ($x=0; $x -lt 5; $x++) {
        [pscustomobject]@{
            dx = $x * $lines[0].Length
            dy = $y * $lines.Count
            inc = $x + $y
        }
    }
}
$expandLimit = ($Part2) ? 25 : 1

# Let's implement Dijkstra's shortest path algorithm using
# a PriorityQueue (since it exists in the BCL now) as described
# here:
# https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Using_a_priority_queue

# Parse the input in a hashtable with coord keys
# and a value that contains risk, "distance" from
# 0,0 (total risk), and neighbors. Distance starts
# as "infinity" for everything but 0,0
$map = @{}
for ($y=0; $y -lt $lines.Count; $y++) {
    for ($x=0; $x -lt $lines[0].Length; $x++) {
        for ($e=0; $e -lt $expandLimit; $e++) {
            $exp = $expDeltas[$e]
            $ex = $x + $exp.dx
            $ey = $y + $exp.dy
            $key = "$ex,$ey"
            $risk = [int]$lines[$y][$x]-48
            $eRisk = ($risk + $exp.inc) % 9
            if ($eRisk -eq 0) { $eRisk = 9 }
            $map[$key] = @{
                key = $key
                risk = $eRisk
                nbrs = $nbrDeltas | %{
                    $nx = $ex + $_[0]
                    $ny = $ey + $_[1]
                    if (-not ($nx -lt 0 -or $ny -lt 0 -or
                        $nx -gt $maxX -or $ny -gt $maxY))
                    {
                        "$nx,$ny"
                    }
                }
                dist = [int]::MaxValue
            }
        }
    }
}
$map['0,0'].dist = 0
$start = $map['0,0']
$end = $map["$maxX,$maxY"]


# create a PriorityQueue with our starting vertex
$pq = [Collections.Generic.PriorityQueue[PSObject,int]]::new()
$pq.Enqueue($start, $start.dist)

# keep track of seen keys
$seen = @{}

$maxQ = 0

$lowestTotalRisk = while ($pq.Count -gt 0) {

    if ($pq.Count -gt $maxQ) { $maxQ = $pq.Count }

    # grab the vertex with the next shortest distance
    $u = $pq.Dequeue()
    #Write-Verbose "checking $($u.key)"

    # check if we're done
    if ($u.key -eq $end.key) {
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
        $newDist = $u.dist + $v.risk
        if ($newDist -lt $v.dist) {
            $v.dist = $u.dist + $v.risk
            $pq.Enqueue($v, $v.dist)
            #Write-Verbose "    queued $($v.key) with dist $($v.dist)"
        }
    }

}
Write-Host "Max queue size $maxQ"
Write-Host "Lowest Total Risk: $lowestTotalRisk"
