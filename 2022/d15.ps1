#Requires -Version 7

[CmdletBinding()]
param(
    [string]$InputFile = '.\d15.txt',
    [switch]$UseExampleParams
)

# https://adventofcode.com/2022/day/15

$Part1Row = 2000000
$Part2Size = 4000000
if ($UseExampleParams) {
    $Part1Row = 10
    $Part2Size = 20
}

class Sensor {
    [int]$x
    [int]$y
    [int]$bx
    [int]$by
    [int]$mdist
    [int]$yMin
    [int]$yMax
    [Collections.Generic.Dictionary[int,int[]]]$cvg

    Sensor([int]$x,[int]$y,[int]$bx,[int]$by) {
        $this.x = $x
        $this.y = $y
        $this.bx = $bx
        $this.by = $by
        $this.mdist = [Math]::Abs($x-$bx) + [Math]::Abs($y-$by)
        $this.yMin = $y - $this.mdist
        $this.yMax = $y + $this.mdist
        $this.cvg = [Collections.Generic.Dictionary[int,int[]]]::new()
    }

    [int[]]GetXCoverage([int]$row) {
        if ($row -lt $this.yMin -or $this.yMax -lt $row) {
            return $null
        }
        $xDelta = $this.mdist - [Math]::Abs($row - $this.y)
        return [int[]]@(($this.x-$xDelta),($this.x+$xDelta))
    }
}

# store beacon references in a hashtable by y-coord with x-coord
# as value to make exempting them by row easier
$beacons = @{}

$sensors = Get-Content $InputFile | ForEach-Object {
    $null,$sx,$sy,$bx,$by = [int[]]($_ -split '[^-0-9]+')
    [Sensor]::new($sx,$sy,$bx,$by)
    $beacons[$by] = $bx
}

# Part 1

Write-Verbose "measuring row $Part1Row"
$xMin = $xMax = 0
$sensors | ForEach-Object {
    if ($range = $_.GetXCoverage($Part1Row)) {
        $xMin = [Math]::Min($xMin,$range[0])
        $xMax = [Math]::Max($xMax,$range[1])
        #,$range
    }
}
#| Sort-Object {$_[0]},{$_[1]}
#| %{ $_ -join ',' }

$covered = $xMax - $xMin + 1
if ($beacons.ContainsKey($Part1Row)) {
    $covered--
}
$covered

# Part 2

function Find-DistressBeacon {
    [CmdletBinding()]
    param()

    for ($i=$Part2Size; $i -ge 0; $i--) {
        if ($i % 100000 -eq 0) { Write-Verbose "starting row $i" }
        # grab and sort all of the x-ranges that have coverage in this row
        $ranges = foreach ($s in $sensors) {
            if ($r = $s.GetXCoverage($i)) {
                # # reduce each range to within the puzzle bounds
                # if ($r[0] -lt 0) { $r[0] = 0 }
                # if ($r[1] -gt $Part2Size) { $r[1] = $Part2Size }
                ,$r
            }
        }
        $ranges = $ranges | Sort-Object -Unique {$_[0]},{$_[1]}
        #$ranges | %{ Write-Verbose "$row $i $($_ -join ',') " }

        # build a consolidated x-range by combining the individual ones
        # while looking for a gap that would be our distress beacon
        $xMin = $ranges[0][0]
        $xMax = $ranges[0][1]
        for ($j=1; $j -lt $ranges.Count; $j++) {

            #Write-Verbose "range $($j-1) of $xMin,$xMax of $Part2Size"
            # stop if the row is fully covered
            if ($xMin -le 0 -and $xMax -ge $Part2Size) {
                #Write-Verbose "row $i fully covered after $($j-1) ranges"
                break
            }

            $r = $ranges[$j]

            # check for gaps
            if ($xMin -gt 0) {
                $lBound = $xMin-1
                if ($r[1] -lt $lBound) {
                    Write-Verbose "row $i found gap at x $lBound"
                    return [int[]]@($lBound,$i)
                }
            }
            if ($xMax -lt $Part2Size) {
                $uBound = $xMax+1
                if ($r[0] -gt $uBound) {
                    Write-Verbose "row $i found gap at x $uBound"
                    return [int[]]@($uBound,$i)
                }
            }
            # update consolidated range
            if ($r[0] -lt $xMin) { $xMin = $r[0] }
            if ($r[1] -gt $xMax) { $xMax = $r[1] }
        }
    }
}

$beacon = Find-DistressBeacon
$beacon[0] * 4000000 + $beacon[1]
