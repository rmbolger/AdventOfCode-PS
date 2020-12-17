[CmdletBinding()]
param(
    [string]$InputFile = '.\d15.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    function Find-NthNumber {
        [CmdletBinding()]
        param(
            [int[]]$StartNumbers,
            [int]$FinalTurn
        )

        # use a hashtable to keep track of the last turn a particular number
        # was spoken
        $prevTurns = @{}
        # add the input values except the last turn
        $StartNumbers[0..($StartNumbers.Count-2)] | % -Begin { $i=0 } -Process {
            $prevTurns[$_] = ++$i
        }

        # set the last value before the next turn
        $lastVal = $nums[-1]

        for ($turn=($StartNumbers.Count+1); $turn -le $FinalTurn; $turn++)
        {
            # get the previous turn for the last number
            $prevTurn = $prevTurns[$lastVal]

            # set the new turn for the last number
            $prevTurns[$lastVal] = $turn - 1

            # set the new last number
            $lastVal = $prevTurn ? ($turn - 1 - $prevTurn) : 0
        }
        $lastVal
    }


    [int[]]$nums = (Get-Content $InputFile -Raw).Trim().Split(',')

# Part 1
if (-not $NoPart1) {

    $val = Find-NthNumber $nums 2020
    Write-Host $val

}


# Part 2
if (-not $NoPart2) {

    $val = Find-NthNumber $nums 30000000
    Write-Host $val

}
