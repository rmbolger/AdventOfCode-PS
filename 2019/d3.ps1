[CmdletBinding()]
param(
    [string]$InputFile = '.\d3.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

function Build-WireMap {
    param($path)

    $x = $y = 0
    $map = @{}
    $dx = @{'L'=-1;'R'=1;'U'=0;'D'= 0 }
    $dy = @{'L'= 0;'R'=0;'U'=1;'D'=-1 }
    $steps = 0

    foreach ($cmd in $path) {

        $dist = $cmd.Substring(1)
        $d = [string]$cmd[0]
        foreach ($i in (1..$dist)) {
            $x += $dx[$d]
            $y += $dy[$d]
            $steps++
            $nextPoint = "$x+$y"
            if (!$map.ContainsKey($nextPoint)) {
                $map[$nextPoint] = $steps
            }
        }
    }

    return $map
}


$lines = Get-Content $InputFile

$path1 = $lines[0].Split(',')
$path2 = $lines[1].Split(',')

$map1 = Build-WireMap $path1
$map2 = Build-WireMap $path2

$intersections = $map1.Keys | ? { $map2.ContainsKey($_) -and $_ -ne "0+0" }

# Part 1
if (-not $NoPart1) {

    # free [Math]::Abs() by replacing '-' with nothing
    $sums = $intersections | % { $_ -replace '-' | iex }
    $minDist = $sums | sort | select -first 1
    Write-Host "Part 1: $minDist"

}

# Part 2
if (-not $NoPart2) {

    $sums = $intersections | % { $map1[$_] + $map2[$_] }
    $minWalk = $sums | sort | select -first 1
    Write-Host "Part 2: $minWalk"

}
