#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d4.txt'
)

# https://adventofcode.com/2022/day/4

    # Part 1 and 2

    $subsets = $overlaps = 0

    Get-Content $InputFile | ForEach-Object {

        # parse the line into the individual values
        $w,$x,$y,$z = $_.Split([char[]]('-',','))

        # convert them into HashSets
        $hs1 = [Collections.Generic.HashSet[int]]::new([int[]]($w..$x))
        $hs2 = [Collections.Generic.HashSet[int]]::new([int[]]($y..$z))

        # increment the subsets if necessary for Part 1
        if ($hs1.IsSubsetOf($hs2) -or $hs2.IsSubsetOf($hs1)) {
            $subsets++
        }

        # increment the overlaps if necessary for Part 2
        if ($hs1.Overlaps($hs2) -or $hs2.Overlaps($hs1)) {
            $overlaps++
        }
    }

    $subsets
    $overlaps
