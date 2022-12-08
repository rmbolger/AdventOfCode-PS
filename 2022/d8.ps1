#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d8.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# https://adventofcode.com/2022/day/8

$rows = Get-Content $InputFile
$xMax = $rows[0].Length-1
$yMax = $rows.Count-1

class Tree {
    [string]$coord
    [int]$x
    [int]$y
    [char]$size
    [char[]]$TreesN
    [char[]]$TreesS
    [char[]]$TreesE
    [char[]]$TreesW
    [bool]$IsEdge=$false
    Tree([int]$x,[int]$y,[char]$size) {
        $this.x = $x
        $this.y = $y
        $this.coord = "$x,$y"
        $this.size = $size
    }
    [string]ToString() {
        return '{0}({1})' -f $this.coord,$this.size
    }
    [void]FetchNeighbors([hashtable]$trees,[int]$xMax,[int]$yMax) {
        if ($this.y -ne 0) {
            $this.TreesN = foreach ($yb in ($this.y-1)..0) {
                $trees["$($this.x),$yb"].size
            }
        }
        else { $this.IsEdge = $true }
        if ($this.y -ne $yMax) {
            $this.TreesS = foreach ($yb in ($this.y+1)..$yMax) {
                $trees["$($this.x),$yb"].size
            }
        }
        else { $this.IsEdge = $true }
        if ($this.x -ne $xMax) {
            $this.TreesE = foreach ($xb in ($this.x+1)..$xMax) {
                $trees["$xb,$($this.y)"].size
            }
        }
        else { $this.IsEdge = $true }
        if ($this.x -ne 0) {
            $this.TreesW = foreach ($xb in ($this.x-1)..0) {
                $trees["$xb,$($this.y)"].size
            }
        }
        else { $this.IsEdge = $true }
    }
    [bool]IsVisible() {
        if ($this.IsEdge -or
            -not ($this.TreesN | Where-Object { $_ -ge $this.size }) -or
            -not ($this.TreesS | Where-Object { $_ -ge $this.size }) -or
            -not ($this.TreesE | Where-Object { $_ -ge $this.size }) -or
            -not ($this.TreesW | Where-Object { $_ -ge $this.size })
        ) {
            return $true
        }
        return $false
    }
    [int]CalcScore() {
        # edges automatically 0
        if ($this.IsEdge) { return 0 }
        $vdN=$vdS=$vdE=$vdW=0
        foreach ($tSize in $this.TreesN) {
            if ($tSize -lt $this.size) { $vdN++ }
            else { $vdN++; break }
        }
        foreach ($tSize in $this.TreesS) {
            if ($tSize -lt $this.size) { $vdS++ }
            else { $vdS++; break }
        }
        foreach ($tSize in $this.TreesE) {
            if ($tSize -lt $this.size) { $vdE++ }
            else { $vdE++; break }
        }
        foreach ($tSize in $this.TreesW) {
            if ($tSize -lt $this.size) { $vdW++ }
            else { $vdW++; break }
        }
        return $vdN*$vdS*$vdE*$vdW
    }
}

$trees = @{}

$y=-1
foreach ($row in (Get-Content $InputFile)) {
    $y++
    $x=-1
    foreach ($size in $row.ToCharArray()) {
        $x++
        $t = [Tree]::New($x,$y,$size)
        $trees[$t.coord] = $t
    }
}

# populate the neighbor sizes
$trees.GetEnumerator() | ForEach-Object {
    $_.Value.FetchNeighbors($trees,$xMax,$yMax)
}

# Part 1
if (-not $NoPart1) {
    # find visible trees in the grid
    $trees.Values
    | Where-Object { $_.IsVisible() }
    | Measure-Object
    | Select-Object -Expand Count
}

# Part 2
if (-not $NoPart2) {
    # find the highest score in the grid
    $trees.Values
    | Select-Object @{L='score';E={$_.CalcScore()}}
    | Sort-Object -Descending score
    | Select-Object -Expand score -First 1
}
