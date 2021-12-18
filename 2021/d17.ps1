#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d17.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/17

$data = Get-Content $InputFile
Set-Clipboard $data

    $x1,$x2,$y2,$y1 = [int[]]((Get-Clipboard) -split '[^-0-9]+' | ?{$_})
    Write-Verbose "target x $x1..$x2, y $y1..$y2"

    # Part 1

    # Because VX decreases until it reaches 0, we can effectively ignore it
    # because the probe will be going straight down. So we just have to make
    # sure VY is not so negative that it overshoots the bottom of the target
    # when it passes Y=0. Assuming VY is positive (which is all we care about
    # for finding the max height), the first step on the way down after passing
    # Y=0 will always be -(VY+1). So the max VY we can use is Abs(Y2)-1.
    #
    # Once we have our VY, calculating the max height is just summing all of the
    # positive numbers less than and including VY which is another way of saying
    # it's a "triangular number":
    # https://en.wikipedia.org/wiki/Triangular_number

    function TriNum($n) { $n * ($n + 1) / 2}

    Write-Host "Part 1: $((TriNum ([Math]::Abs($y2)-1)))"

    # Part 2

    # We're going to effectively brute force this. But we should figure out
    # some reasonable bounds for our loops.

    # VX trends towards 0 making its total potential forward distance another
    # triangular number. The lowest VX we can have must have a total distance of
    # at least X1. And it can't be any higher than X2.
    $maxVX = $x2
    $minVX = for ($vx=1; $vx -le $maxVX; $vx++) {
        if ((TriNum $vx) -ge $x1) {
            Write-Verbose "vx($vx) -> dist($(TriNum $vx)) which is -ge x1($x1)"
            $vx
            break
        }
    }
    Write-Verbose "VX range $minVX..$maxVX"

    # We already figured the max VY in part one is Abs(Y2)-1 and the minimum
    # is just going to be Y2 because any less and the first step would overshoot
    $maxVY = [Math]::Abs($y2) - 1
    $minVY = $y2
    Write-Verbose "VY range $minVY..$maxVY"

    # Now check all the combos
    $totalHits = 0
    for ($vx0=$minVX; $vx0 -le $maxVX; $vx0++) {
        for ($vy0=$minVY; $vy0 -le $maxVY; $vy0++) {

            $x = $y = $step = 0
            $vx = $vx0
            $vy = $vy0

            # loop while we haven't passed either far edge
            while ($x -le $x2 -and $y -ge $y2) {
                # check for a hit
                if ($x -ge $x1 -and $y -le $y1) {
                    $totalHits += 1
                    #Write-Verbose "hit for vXY = $vx0,$vy0 on step $step at XY=$x,$y ($x1..$x2,$y1..$y2)"
                    break
                }

                # take a step
                $x += $vx
                $y += $vy
                $step++
                $vy -= 1
                if ($vx -gt 0) { $vx -= 1 }
            }
        }
    }
    Write-Host "Part 2: $totalHits"
