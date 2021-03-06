#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d21.txt'
)

# https://adventofcode.com/2021/day/21

$data = Get-Content $InputFile -Raw
Set-Clipboard $data

    $null,[int]$p1Start,$null,[int]$p2Start = (Get-Clipboard -Raw) -split '\D' | ?{$_}

# Part 1

    # play on 0-9 board instead of 1-10 board so mod math makes sense
    # then just add 1 to resulting space for score
    $p1Pos = $p1Start - 1
    $p2Pos = $p2Start - 1
    $p1Score=$p2Score=0
    $dd = -1
    $turnP1 = $true
    while ($p1Score -lt 1000 -and $p2Score -lt 1000) {

        # make 3 rolls
        $roll = 0
        for ($i=0; $i -lt 3; $i++) {
            $dd++
            $roll += ($dd % 100) + 1
        }

        # move and score the appropriate player
        if ($turnP1) {
            $p1Pos += $roll
            $p1Score += ($p1Pos % 10) + 1
            #Write-Verbose "p1 move $roll, new score $p1Score"
        } else {
            $p2Pos += $roll
            $p2Score += ($p2Pos % 10) + 1
            #Write-Verbose "p2 move $roll, new score $p2Score"
        }

        $turnP1 = !$turnP1
    }
    if ($turnP1) {
        Write-Host "Part 1: $($p1Score*($dd+1))"
    } else {
        Write-Host "Part 1: $($p2Score*($dd+1))"
    }


# Part 2
    # create a hashtable to hold potential game states
    # 10 board positions per player, 21 score possibilities per player
    # 10 * 10 * 21 * 21 = 44100 * 2(capacity buffer) = 88200
    $gameStates = [Collections.Generic.Dictionary[string,long[]]]::new(88200)

    # roll variations
    $rollStates = @(
        ,@(3,1) # 111
        ,@(4,3) # 112,121,211
        ,@(5,6) # 122,212,221,311,131,113
        ,@(6,7) # 123,132,213,231,312,321,222
        ,@(7,6) # 322,232,223,331,313,133
        ,@(8,3) # 332,323,233
        ,@(9,1) # 333
    )

    function Invoke-DiracDice {
        [CmdletBinding()]
        param(
            [int]$pAPos,
            [int]$pBPos,
            [int]$pAScore = 0,
            [int]$pBScore = 0
        )

        # return 1 for the winner and 0 for the loser
        if ($pAScore -ge 21) { return 1,0 }
        if ($pBScore -ge 21) { return 0,1 }

        # return the cached state if we've seen it already
        $stateKey = '{0},{1},{2},{3}' -f $pAPos,$pBPos,$pAScore,$pBScore
        if ($gameStates.ContainsKey($stateKey)) {
            return $gameStates[$stateKey]
        }

        [long[]]$wins = 0,0

        foreach ($roll in $rollStates) {
            # update position and score
            $pAPosNew = ($pAPos + $roll[0]) % 10
            $pAScoreNew = $pAScore + $pAPosNew + 1

            # recurse but flip player A/B to take turns
            $pAWins,$pBWins = Invoke-DiracDice $pBPos $pAPosNew $pBScore $pAScoreNew

            # Update the win counts from the unrolled recursive
            # recursive turns (reversed because it was from the
            # previous turn where players were swapped)
            # Multiply the wins by the number of roll states for
            # this roll
            $wins[0] += $pBWins * $roll[1]
            $wins[1] += $pAWins * $roll[1]
        }

        # cache this game state
        $gameStates[$stateKey] = $wins

        return $wins
    }

    $mostWins = Invoke-DiracDice ($p1Start-1) ($p2Start-1) | sort -desc | select -first 1
    Write-Host "Part 2: $mostWins"
