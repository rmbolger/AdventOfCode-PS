#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d10.txt'
)

# https://adventofcode.com/2022/day/10

$cycle = 1
[int]$x = 1
$sprite = 0,1,2
$crt = @(
    '                                        '.ToCharArray(),
    '                                        '.ToCharArray(),
    '                                        '.ToCharArray(),
    '                                        '.ToCharArray(),
    '                                        '.ToCharArray(),
    '                                        '.ToCharArray()
)
$crtLine = 0

$strengths = switch -Regex (Get-Content $InputFile) {

    'noop' {
        if (($cycle-1)%40 -in $sprite) {
            $crt[$crtLine][($cycle-1)%40] = '#'
        }
        #Write-Verbose "c$cycle x$x noop - $($crt[$crtLine] -join '') - row $crtLine"

        if ($cycle%40 -eq 0) {
            $crtLine++
            #Write-Verbose "c$cycle crt$crtLine"
        }
        $cycle++
        if (($cycle-20)%40 -eq 0) {
            $cycle * $x
            #Write-Verbose "c$cycle * x$x = $($cycle*$x)"
        }

    }
    'addx (\S+)' {
        $addx = $matches[1]

        if (($cycle-1)%40 -in $sprite) {
            $crt[$crtLine][($cycle-1)%40] = '#'
        }
        #Write-Verbose "c$cycle x$x $addx - $($crt[$crtLine] -join '') - row $crtLine"

        if ($cycle%40 -eq 0) {
            $crtLine++
            #Write-Verbose "c$cycle crt$crtLine"
        }
        $cycle++
        if (($cycle-20)%40 -eq 0) {
            $cycle * $x
            #Write-Verbose "c$cycle * x$x = $($cycle*$x)"
        }

        if (($cycle-1)%40 -in $sprite) {
            $crt[$crtLine][($cycle-1)%40] = '#'
        }
        #Write-Verbose "c$cycle x$x $addx - $($crt[$crtLine] -join '') - row $crtLine"

        $x += $addx
        $sprite = ($x-1),$x,($x+1)

        if ($cycle%40 -eq 0) {
            $crtLine++
            #Write-Verbose "c$cycle crt$crtLine"
        }
        $cycle++
        if (($cycle-20)%40 -eq 0) {
            $cycle * $x
            #Write-Verbose "c$cycle * x$x = $($cycle*$x)"
        }
    }
}
$strengths | Measure-Object -Sum
| Select-Object -Expand Sum

# Part 2 Output
$crt | ForEach-Object { $_ -join '' }
