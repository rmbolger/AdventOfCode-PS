#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d5.txt'
)

# https://adventofcode.com/2021/day/5

$data = Get-Content $InputFile
Set-Clipboard $data

<# Sample

    0  1  2  3  4  5  6  7  8   timer val
    -------------------------
    1  1  2  1               count
    1  1  2  1
    1  2  1           1     1
    2  1           1  1  1  1
    1           1  1  3  1  2
#>

    # populate the initial timer count tracker
    [long[]]$t = @(0,0,0,0,0,0,0,0,0)
    [long[]]((gcb) -split ',') | %{
        $t[$_] += 1
    }

    function Invoke-Lifecycle {
        [CmdletBinding()]
        param(
            [long[]]$t,
            [int]$Days=80
        )

        for ($d=0; $d -lt $Days; $d++) {
            # save the current 0 value
            $zeroCount = $t[0]

            # shift everything down except 0
            (1..8).foreach{ $t[$_-1] = $t[$_] }

            # add former 0 val to 6 and 8
            $t[6] += $zeroCount
            $t[8] = $zeroCount
            #Write-Verbose ($t -join ',')
        }

        # return $t
        $t
    }

    # Part 1
    (Invoke-Lifecycle $t | Measure-Object -Sum).Sum

    # Part 2
    # initial 80 day state remains, so just run it again for the rest
    (Invoke-Lifecycle $t -Days (256-80) | Measure-Object -Sum).Sum
