#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d11.txt'
)

# https://adventofcode.com/2022/day/11

class Monkey {
    [Collections.Generic.Queue[long]]$items
    [string]$operation
    [int]$divTest
    [int[]]$throwIndex
    [Monkey]$throwTrue
    [Monkey]$throwFalse
    [int]$inspect = 0

    Monkey([string]$inputRaw) {
        $lines = $inputRaw -split "`n"
        $this.items = [Collections.Generic.Queue[long]]::new(
            [long[]]($lines[1].Substring(18)|Invoke-Expression)
        )
        $this.operation = $lines[2].Substring(23)
        $this.divTest = $lines[3].Substring(21)
        $this.throwIndex = @(
            $lines[4].Substring(29),
            $lines[5].Substring(30)
        )
    }

    [string]ToString() {
        return ($this.items -join ',')
    }

    [void]TakeTurn([int]$LCM) {
        # end the turn if we have no items to inspect
        if ($this.items.Count -eq 0) { return }

        # loop through the items in order
        foreach ($i in $this.items) {

            # increment the inspections for this monkey
            $this.inspect++

            # run the worry increase operation
            if ($this.operation -eq '* old') {
                $i *= $i
            } elseif ($this.operation[0] -eq '*') {
                $i *= $this.operation.Substring(2)
            } else {
                $i += $this.operation.Substring(2)
            }

            # Part 1 (no LCM) just divide by 3 rounded down
            # Part 2 take the modulo of the LCM to "keep our
            # worry levels manageable" without breaking the
            # division test that will happen next
            $i = ($LCM -gt 0) ? $i % $LCM : [Math]::Floor($i / 3)

            # throw it to the appropriate monkey
            if (($i % $this.divTest) -eq 0) {
                $this.throwTrue.items.Enqueue($i)
            } else {
                $this.throwFalse.items.Enqueue($i)
            }
        }
        # empty the queue
        $this.items.Clear()
    }
}

function Invoke-KeepAway {
    param(
        [string[]]$monkeysRaw,
        [switch]$Part2
    )

    # load the monkeys and add throw-to references
    $monkeys = $monkeysRaw | ForEach-Object { [Monkey]::new($_) }
    $monkeys | ForEach-Object {
        $_.throwTrue  = $monkeys[$_.throwIndex[0]]
        $_.throwFalse = $monkeys[$_.throwIndex[1]]
    }

    if (-not $Part2) {
        $rounds = 20
        $LCM = 0
    } else {
        $rounds = 10000
        # calculate the LCM (Least Common Multiple) of the division test
        # for each monkey. All of them are conveniently prime so LCM is
        # just all the tests multiplied together.
        $LCM = $monkeys.divTest -join '*' | Invoke-Expression
    }

    for ($r=0; $r -lt $rounds; $r++) {
        foreach ($mk in $monkeys) {
            $mk.TakeTurn($LCM)
        }
    }

    ($monkeys | Sort-Object inspect)[-1,-2].inspect -join '*' | Invoke-Expression

}

# shared
$monkeysRaw = (Get-Content $InputFile -Raw).Trim() -split "`n`n"

# Part 1
Invoke-KeepAway $monkeysRaw

# Part 2
Invoke-KeepAway $monkeysRaw -Part2
