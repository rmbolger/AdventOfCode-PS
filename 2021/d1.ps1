#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d1.txt'
)

# https://adventofcode.com/2021/day/1

[int[]]$depths = Get-Content $InputFile

# Part 1
$increases = 0
for ($i=1; $i -lt $depths.Count; $i++) {
    if ($depths[$i] -gt $depths[$i-1]) {
        $increases++
    }
}
$increases

# Part 2
$increases = 0
$lastWindow = $depths[0] + $depths[1] + $depths[2]
for ($i=3; $i -lt $depths.Count; $i++) {
    $windowTotal = $depths[$i] + $depths[$i-1] + $depths[$i-2]
    if ($windowTotal -gt $lastWindow) {
        $increases++
    }
    $lastWindow = $windowTotal
}
$increases

$depths | Set-Clipboard

# Combined + Partially Minimized
[int[]]$d=gcb
$x=$y=0
$l=$d[0]+$d[1]+$d[2]
1..($d.Count)|%{
    if($d[$_] -gt $d[$_-1]){
        $x++
    }
    if($_ -ge 3){
        if(($t=$d[$_]+$d[$_-1]+$d[$_-2]) -gt $l){
            $y++
        }
        $l=$t
    }
}
$x
$y

# Golfed - 161 chars
[int[]]$d=gcb;$x=$y=0;$l=$d[0]+$d[1]+$d[2];1..($d.Count)|%{if($d[$_] -gt $d[$_-1]){$x++};if($_ -ge 3){if(($t=$d[$_]+$d[$_-1]+$d[$_-2]) -gt $l){$y++}$l=$t}};$x;$y
