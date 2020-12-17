[CmdletBinding()]
param(
    [string]$InputFile = '.\d3.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$d3 = Get-Content $InputFile

function Get-HitTrees {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string[]]$Map,
        [Parameter(Mandatory,Position=1)]
        [int]$Right,
        [Parameter(Mandatory,Position=2)]
        [int]$Down
    )

    # Each row in my map was 31 characters. But in case it's variable,
    # check the length of the first map line and use that.
    $mapWidth = $Map[0].Length

    $x = $y = $trees = 0
    while ($y -lt ($Map.Count-1)) {
        $x += $Right
        $y += $Down
        if ($Map[$y][$x % $mapWidth] -eq '#') {
            $trees += 1
        }
        Write-Verbose "y=$($y.ToString('000')) - $($Map[$y]) - x=$($x.ToString('000')) - mod=$(($x % $mapWidth).ToString('00')) - chr = $($Map[$y][$x % $mapWidth]) - total = $trees"
    }

    return $trees
}

# Part 1
if (-not $NoPart1) {
    Get-HitTrees $d3 3 1
}

# Part 2
if (-not $NoPart2) {
    $treesPerRun = @(1,1),@(3,1),@(5,1),@(7,1),@(1,2) | ForEach-Object {
        Get-HitTrees $d3 $_[0] $_[1]
    }
    Write-Verbose ($treesPerRun -join ' * ')
    $answer = 1
    $treesPerRun | ForEach-Object { $answer = $answer * $_ }
    $answer
}
