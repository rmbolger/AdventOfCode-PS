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
    [bool]$IsVisible=$true
    [int]$Score=0

    Tree([int]$x,[int]$y,[char]$size) {
        $this.x = $x
        $this.y = $y
        $this.coord = "$x,$y"
        $this.size = $size
    }

    [string]ToString() {
        return '{0}({1})' -f $this.coord,$this.size
    }

    [void]SurveyNeighbors([hashtable]$trees,[int]$xMax,[int]$yMax) {

        $visN=$visS=$visE=$visW=$true   # visible
        $vdN=$vdS=$vdE=$vdW=0           # view distance

        # walk north
        if ($this.y -ne 0) {
            foreach ($yb in ($this.y-1)..0) {
                $t = $trees["$($this.x),$yb"]
                $vdN++
                if ($t.size -ge $this.size) {
                    $visN = $false
                    break
                }
            }
        }

        # walk south
        if ($this.y -ne $yMax) {
            foreach ($yb in ($this.y+1)..$yMax) {
                $t = $trees["$($this.x),$yb"]
                $vdS++
                if ($t.size -ge $this.size) {
                    $visS = $false
                    break
                }
            }
        }

        # walk east
        if ($this.x -ne $xMax) {
            foreach ($xb in ($this.x+1)..$xMax) {
                $t = $trees["$xb,$($this.y)"]
                $vdE++
                if ($t.size -ge $this.size) {
                    $visE = $false
                    break
                }
            }
        }

        # walk west
        if ($this.x -ne 0) {
            foreach ($xb in ($this.x-1)..0) {
                $t = $trees["$xb,$($this.y)"]
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
        $t = [Tree]::New($x,$y,$size)
        $trees[$t.coord] = $t
    }
}

# survey the neighbors to calculate whether each tree
# is visible from outside and how many neighbors it has
# that are visible
$trees.Values | ForEach-Object {
    $_.SurveyNeighbors($trees,$xMax,$yMax)
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
