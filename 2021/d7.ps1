#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d7.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# https://adventofcode.com/2021/day/7

$data = Get-Content $InputFile
Set-Clipboard $data

    $pos = [int[]]((gcb) -split ',') | Sort-Object

# Part 1
if (-not $NoPart1) {

    $median = if ($pos.Count % 2) {
        $pos[[Math]::Floor($pos.Count/2)]
    } else {
        $pos[$pos.Count/2],$pos[$pos.Count/2-1] | measure -average | % average
    }
    Write-Verbose "median = $median"

    $pos | %{ [Math]::Abs($_ - $median) } | measure -sum | % sum

}

# Part 2
if (-not $NoPart2) {

    # lookup table for distance costs
    $costs = @{}
    0..$pos[-1] | %{
        $total += $_
        $costs.$_ = $total
    }

    # The "quick" way to do part 2 involves the mean/average of the available
    # positions. But there seems to be some mathmatical variation among puzzle
    # sets whether the average should be Floored or Rounded. To (hopefully)
    # ensure any puzzle set works, we'll just calculate both and use whichever
    # is better.

    $roundMean = [int][Math]::Round(($pos | measure -Average).Average)
    $floorMean = [int][Math]::Floor(($pos | measure -Average).Average)
    Write-Verbose "mean (rounded) = $roundMean, mean (floor) = $floorMean"

    $roundMean,$floorMean | %{
        $mean = $_
        $fuel = $pos | %{
            $delta = [Math]::Abs($_ - $mean)
            $costs.$delta
        } | measure -sum | % sum
        [pscustomobject]@{
            pos = $mean
            fuel = $fuel
        }
    } | sort fuel | select -first 1

    # old brute force parallel implementation

    # # a bit of parallel processing to brute force all of the possibilities
    # $pos[0]..$pos[-1] | ForEach-Object -Parallel {
    #     $p = $_
    #     $fuel = $using:pos | %{
    #         $delta = [Math]::Abs($_ - $p)
    #         ($using:costs)[$delta]
    #     } | measure -sum | % sum
    #     [pscustomobject]@{
    #         pos = $p
    #         fuel = $fuel
    #     }
    # } | sort fuel | select -first 1 -expand fuel

}
