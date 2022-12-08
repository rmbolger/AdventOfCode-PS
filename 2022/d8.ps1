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

# make a 2D array of coordinates so we can lookup keys by y/x value
# rather than allocate new strings every time
$coords = for ($y=0; $y-le$yMax; $y++) { $row = for ($x=0; $x-le$xMax; $x++) {"$x,$y"}; ,$row }

class Tree {
    [string]$coord
    [int]$x
    [int]$y
    [char]$size
    [bool]$IsVisible=$true
    [int]$Score=0

    Tree([int]$x,[int]$y,[char]$size,[string]$coord) {
        $this.x = $x
        $this.y = $y
        $this.coord = $coord
        $this.size = $size
    }

    [string]ToString() {
        return '{0}({1})' -f $this.coord,$this.size
    }

    [void]SurveyNeighbors([hashtable]$trees,[int]$xMax,[int]$yMax,[object[]]$coords) {

        $visN=$visS=$visE=$visW=$true   # visible
        $vdN=$vdS=$vdE=$vdW=0           # view distance

        # walk north
        if ($this.y -ne 0) {
            for ($yb=($this.y-1); $yb -ge 0; $yb--) {
                $t = $trees[$coords[$yb][$this.x]]
                $vdN++
                if ($t.size -ge $this.size) {
                    $visN = $false
                    break
                }
            }
        }

        # walk south
        if ($this.y -ne $yMax) {
            for ($yb=($this.y+1); $yb -le $yMax; $yb++) {
                $t = $trees[$coords[$yb][$this.x]]
                $vdS++
                if ($t.size -ge $this.size) {
                    $visS = $false
                    break
                }
            }
        }

        # walk east
        if ($this.x -ne $xMax) {
            for ($xb=($this.x+1); $xb -le $xMax; $xb++) {
                $t = $trees[$coords[$this.y][$xb]]
                $vdE++
                if ($t.size -ge $this.size) {
                    $visE = $false
                    break
                }
            }
        }

        # walk west
        if ($this.x -ne 0) {
            for ($xb=($this.x-1); $xb -ge 0; $xb--) {
                $t = $trees[$coords[$this.y][$xb]]
                $vdW++
                if ($t.size -ge $this.size) {
                    $visW = $false
                    break
                }
            }
        }

        $this.IsVisible = $visN -or $visS -or $visE -or $visW
        $this.Score = $vdN * $vdS * $vdE * $vdW
    }

}

# populate a hashtable with the coordinate keys
# and Tree objects which includes the size
$trees = @{}
$y=-1
foreach ($row in (Get-Content $InputFile)) {
    $y++
    $x=-1
    foreach ($size in $row.ToCharArray()) {
        $x++
        $t = [Tree]::New($x,$y,$size,$coords[$y][$x])
        $trees[$t.coord] = $t
    }
}

# survey the neighbors to calculate whether each tree
# is visible from outside and how many neighbors it has
# that are visible
$trees.Values | ForEach-Object {
    $_.SurveyNeighbors($trees,$xMax,$yMax,$coords)
}

# Part 1

# find visible trees in the grid
$trees.Values
| Where-Object { $_.IsVisible }
| Measure-Object
| Select-Object -Expand Count

# Part 2

# find the highest score in the grid
$trees.Values
| Sort-Object -Descending Score
| Select-Object -Expand Score -First 1
