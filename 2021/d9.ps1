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

    # create a few dictionaries to hold parsed info we'll need later
    $xyVals = [Collections.Generic.Dictionary[string,int]]::new($mapW*$mapH*2)
    $xyNbrs = [Collections.Generic.Dictionary[string,string[]]]::new($mapW*$mapH*2)
    $xyNbrVals = [Collections.Generic.Dictionary[string,int[]]]::new($mapW*$mapH*2)

    # Save the low points for part 2 while sum'ing their risks for part 1
    # Loop through the non-border x,y's
    $lowPoints = for ($y=1; $y -le $mapH; $y++) {
        for ($x=1; $x -le $mapW; $x++) {

            $val = $caves[$y][$x]

            # skip 9's because they can't be a low point we don't care about neighbors
            if ($val -eq 9) { continue }

            $key = "$x,$y"
            $xyVals.$key = $val

            #$up=$rt=$dn=$lt=9

            # save the non-9 neighbor coords
            if (($up = $caves[$y-1][$x]) -ne 9) {
                $xyNbrs.$key += @("$x,$($y-1)")
            }
            if (($rt = $caves[$y][$x+1]) -ne 9) {
                $xyNbrs.$key += @("$($x+1),$y")
            }
            if (($dn = $caves[$y+1][$x]) -ne 9) {
                $xyNbrs.$key += @("$x,$($y+1)")
            }
            if (($lt = $caves[$y][$x-1]) -ne 9) {
                $xyNbrs.$key += @("$($x-1),$y")
            }

            if ($up -le $val -or
                $rt -le $val -or
                $dn -le $val -or
                $lt -le $val) { continue }

            # no neighbors disqualify, so this is a low point
            #Write-Verbose "$x,$y = $val (risk $([int]$val+1))"
            $risk += $val+1
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
        $xyNbrs[$Key] | %{
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
