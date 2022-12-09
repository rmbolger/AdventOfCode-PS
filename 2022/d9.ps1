#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d9.txt'
)

# https://adventofcode.com/2022/day/9

# Calculate the max range for our puzzle input starting from 0,0
# $x=$y=$xMax=$xMin=$yMax=$yMin=0
# switch -Regex (gc $InputFile) {
#     '(.) (\d+)' {
#         switch ($matches[1]) {
#             'U' { $y += $matches[2]; $yMax = [Math]::Max($y,$yMax) }
#             'D' { $y -= $matches[2]; $yMin = [Math]::Min($y,$yMin) }
#             'L' { $x -= $matches[2]; $xMin = [Math]::Min($x,$xMin) }
#             'R' { $x += $matches[2]; $xMax = [Math]::Max($x,$xMax) }
#         }
#         '{0} - {1},{2} - {3},{4} - {5},{6}' -f $matches[0],$x,$y,$xMax,$yMax,$xMin,$yMin
#     }
# }
# exit

# Delta values to directional pull
# .......
# .HHHHH. UL(2,-2 + 1,-2) U(0,-2) UR(-1,-2 + -2,-2)
# .H...H. UL(2,-1)                UR(-2,-1)
# .H.T.H.  L(2, 0)                 R(-2, 0)
# .H...H. DL(2, 1)                DR(-2, 1)
# .HHHHH. DL(2, 2 + 1, 2)         DR(-1, 2 + -2, 2)
# .......

# We're going to be encoding x,y coordinates (up to 15 bits = 32767) as
# a single [int]. So we'll want functions that can convert between the two.
function CoordToKey {
    param([int]$x,[int]$y)
    $x -shl 15 -bor $y
}
function KeyToCoord {
    param([int]$key)
    $x = $key -shr 15 -band 32767
    $y = $key -band 32767
    $x,$y
}

class Knot {
    [int]$x=1000
    [int]$y=1000
    [Collections.Generic.HashSet[int]]$hist
    [Knot]$next
    [hashtable]$dirMap = @{
        U  =  0, 1
        D  =  0,-1
        R  =  1, 0
        L  = -1, 0
        UR =  1, 1
        DR =  1,-1
        DL = -1,-1
        UL = -1, 1
    }

    Knot([int]$children) {
        if ($children -gt 0) {
            $this.next = [Knot]::new($children-1)
        } else {
            # last knot tracks history
            $this.hist = [Collections.Generic.HashSet[int]]::new()
            $this.hist.Add((CoordToKey $this.tx $this.ty))
        }
    }

    [string]ToString() {
        if ($this.next) {
            return '({0},{1})->{2}' -f ($this.x),($this.y),$this.next
        } else {
            return '({0},{1})' -f ($this.x),($this.y)
        }
    }

    [Collections.Generic.HashSet[int]]GetTailHistory() {
        if ($this.next) {
            return $this.next.GetTailHistory()
        } else {
            return $this.hist
        }
    }

    # define a 2D array to quickly get the direction based on deltas
    [string[][]]$coordDir = @(
        @('UR', 'UR',  'U', 'UL','UL'),
        @('UR',$null,$null,$null,'UL'),
        @( 'R',$null,$null,$null, 'L'),
        @('DR',$null,$null,$null,'DL'),
        @('DR', 'DR',  'D', 'DL','DL')
    )

    [void]Move([string]$dir) {

        # move this knot
        $delta = $this.dirMap[$dir]
        $this.x += $delta[0]
        $this.y += $delta[1]

        # add to history if we're the last
        if (-not $this.next) {
            $this.hist.Add((CoordToKey $this.x $this.y))
            return
        }

        # see if we need to "pull" the next knot by converting the delta
        # on each axis to a string direction from our map
        $dx = $this.next.x - $this.x + 2
        $dy = $this.next.y - $this.y + 2
        if ($childMove = $this.coordDir[$dy][$dx]) {
            #Write-Verbose "sending $childMove to child"
            $this.next.Move($childMove)
        }
    }

}

# Part 1

# create the 2 linked knots
$knot = [Knot]::new(1)

# run the simulation
foreach ($line in (Get-Content $InputFile)) {
    $dir,[int]$qty = $line -split '\s'
    for ($i=0; $i -lt $qty; $i++) {
        $knot.Move($dir)
    }
}

# check answer
$knot.GetTailHistory().Count

# Part 2

# create the 10 linked knots
$knot = [Knot]::new(9)

# run the simulation
foreach ($line in (Get-Content $InputFile)) {
    $dir,[int]$qty = $line -split '\s'
    for ($i=0; $i -lt $qty; $i++) {
        $knot.Move($dir)
    }
}

# check answer
$knot.GetTailHistory().Count
