#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d9.txt',
    [switch]$NoPart2
)

# https://adventofcode.com/2021/day/9

$data = Get-Content $InputFile
Set-Clipboard $data

# Part 1

    # create a 2x2 array with a border of 9's for the input
    [int[][]]$caves = gcb | %{ ,( [char[]]"9$($_)9" | %{ $_-48 } ) }
    $mapW = $caves[0].Count - 2
    $mapH = $caves.Count
    $top = ,(@(9)*($mapW+2))
    $caves = $top + $caves + $top

    # while we find the low points, we're going to save the coordinates of
    # every potential basin point and its basin neighbors in a dictionary.
    $nbrs = [Collections.Generic.Dictionary[string,string[]]]::new($mapW*$mapH*2)

    # find the low points for part 2 while calculating the risk for part 1
    $lowPoints = for ($y=1; $y -le $mapH; $y++) {
        for ($x=1; $x -le $mapW; $x++) {

            $pt = $caves[$y][$x]

            # can't be a low point at 9 and don't care about neighbors
            if ($pt -eq 9) { continue }

            $key = "$x,$y"
            $up=$rt=$dn=$lt=9

            # check each neighbor
            if (($up = $caves[$y-1][$x]) -ne 9) {
                $nbrs.$key += @("$x,$($y-1)")
            }
            if (($rt = $caves[$y][$x+1]) -ne 9) {
                $nbrs.$key += @("$($x+1),$y")
            }
            if (($dn = $caves[$y+1][$x]) -ne 9) {
                $nbrs.$key += @("$x,$($y+1)")
            }
            if (($lt = $caves[$y][$x-1]) -ne 9) {
                $nbrs.$key += @("$($x-1),$y")
            }

            if ($up -le $pt -or
                $rt -le $pt -or
                $dn -le $pt -or
                $lt -le $pt) { continue }

            # no neighbors disqualify, so this is a low point
            #Write-Verbose "$x,$y = $pt (risk $([int]$pt+1))"
            $risk += $pt+1
            $key
        }
    }

    $risk
    Write-Verbose "$($lowPoints.Count) low points"

# Part 2
if (-not $NoPart2) {

    function Get-BasinNeighbors {
        [CmdletBinding()]
        param(
            [string]$Key,
            [string[]]$Exclude
        )

        # first return and exclude yourself
        #Write-Verbose "    ret $Key"
        $Key
        $Exclude += $Key

        # now check the neighbors if there are any
        $nbrs[$Key] | %{
            if ($_ -notin $Exclude) {
                #Write-Verbose "Recurse $_ excluding $($Exclude -join '|')"
                $newNeighbors = Get-BasinNeighbors $_ $Exclude -Verbose | Select-Object -Unique
                $Exclude += $newNeighbors
                $newNeighbors
            }
            #else { Write-Verbose "Skip    $_" }
        }
    }

    # Every non-9 can only be part of 1 basin. So start
    # with the low points and follow unique non-9 neighbors
    $basinSizes = $lowPoints | %{
        $n = Get-BasinNeighbors $_ @()
        $n.Count
        #Write-Verbose ($n -join '|')
    }
    $s3 = $basinSizes | Sort-Object -Descending | Select-Object -First 3
    $s3[0]*$s3[1]*$s3[2]

}
