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
$d=gcb|%{+$_}
$x=$y=0
$l=$d[0]+$d[1]+$d[2]
1..($d.Count)|%{
    $x+=$d[$_]-gt$d[$_-1]
    if($_-ge3){
        $y+=($t=$d[$_]+$d[$_-1]+$d[$_-2])-gt$l
        $l=$t
    }
}
$x
$y

# Golfed - 144 chars
[int[]]$d=gcb;$x=$y=0;$l=$d[0]+$d[1]+$d[2];1..($d.Count)|%{$x+=$d[$_]-gt$d[$_-1];if($_-ge3){$y+=($t=$d[$_]+$d[$_-1]+$d[$_-2])-gt$l;$l=$t}};$x;$y


# u/bis fun pipeline solution
$x=$y=0  # number of positive deltas and windowed-deltas
gcb | # get the puzzle input from the clipboard
%{+$_}-ov L| # make the string into a number, and put the output so far into $L

# make objects to better visualize the two sequences, using -PipelineVariable to look at
# the prior input value ($p)
select -first 50 @{n='N';e={$_}}, @{n='N3';e={if($L.Count -ge 3){$L[-1]+$L[-2]+$L[-3]}}} |
select *, @{n='D';e={if($p){$_.N-$p.N}}}, @{N='D3';e={if($null-ne$p.N3){$_.N3-$p.N3}}} -pv p |

# hackily calculate the count of the two types of deltas, using the fact that $true = 1, $false = 0
%{$x+=$_.D-gt0; $y+=$_.D3-gt0}

$x
$y
