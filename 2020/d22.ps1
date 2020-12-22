[CmdletBinding()]
param(
    [string]$InputFile = '.\d22.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# parse the input and add each "hand" to a Queue object
$p1part,$p2part = (Get-Content $InputFile -Raw).Trim() -split "`n`n"
$p1array = [int[]]($p1part -split "`n" | Select-Object -Skip 1)
$p2array = [int[]]($p2part -split "`n" | Select-Object -Skip 1)
$p1 = [Collections.Generic.Queue[int]]::new($p1array)
$p2 = [Collections.Generic.Queue[int]]::new($p2array)


# Part 1
if (-not $NoPart1) {

    # play war
    # part 1 text doesn't mention what happens for a tie,
    # so assume they won't happen for now
    while ($p1.Count -gt 0 -and $p2.Count -gt 0) {
        $c1 = $p1.Dequeue()
        $c2 = $p2.Dequeue()
        if ($c1 -gt $c2) {
            $p1.Enqueue($c1)
            $p1.Enqueue($c2)
        } else {
            $p2.Enqueue($c2)
            $p2.Enqueue($c1)
        }
    }
    $winner = ($p1.Count -eq 0) ? $p2 : $p1

    # calculate the winner's score
    $score = 0
    foreach ($mult in ($winner.Count..1)) {
        $nextCard = $winner.Dequeue()
        $score += $nextCard * $mult
    }
    Write-Host $score

}


# Part 2
if (-not $NoPart2) {

    # reset the decks
    $p1 = [Collections.Generic.Queue[int]]::new($p1array)
    $p2 = [Collections.Generic.Queue[int]]::new($p2array)

    function Play-SubGame {
        param(
            [int]$p1c,
            [int]$p2c,
            [Collections.Generic.Queue[int]]$p1,
            [Collections.Generic.Queue[int]]$p2
        )

        # track the round states with a hashset
        $rounds = [Collections.Generic.Hashset[string]]::new()

        # play recursive war
        while ($p1.Count -gt 0 -and $p2.Count -gt 0) {

            # check for duplicate gamestate
            $gamestate = "$($p1.ToArray() -join ',')|$($p2.ToArray() -join ',')"
            if (-not $rounds.Add($gamestate)) {
                # we've already played round, p1 wins
                #Write-Verbose "dupe round detected, player 1 wins: $gamestate"
                return $p1c,$p1
            }
            #Write-Verbose "gamestate: $gamestate"

            $c1 = $p1.Dequeue()
            $c2 = $p2.Dequeue()
            # are there enough cards to recurse?
            if ($p1.Count -ge $c1 -and $p2.Count -ge $c2) {
                # create the sub-decks
                $p1SubCards = [int[]]($p1.ToArray()[0..($c1-1)])
                $p2SubCards = [int[]]($p2.ToArray()[0..($c2-1)])
                $p1Sub = [Collections.Generic.Queue[int]]::new($p1SubCards)
                $p2Sub = [Collections.Generic.Queue[int]]::new($p2SubCards)
                # play the sub-game
                $winCard,$null = Play-SubGame $c1 $c2 $p1Sub $p2Sub
                if ($winCard -eq $c1) {
                    $p1.Enqueue($c1)
                    $p1.Enqueue($c2)
                } else {
                    $p2.Enqueue($c2)
                    $p2.Enqueue($c1)
                }
            }
            elseif ($c1 -gt $c2) {
                $p1.Enqueue($c1)
                $p1.Enqueue($c2)
            }
            else {
                $p2.Enqueue($c2)
                $p2.Enqueue($c1)
            }
        }
        if ($p1.Count -eq 0) {
            return $p2c,$p2
        } else {
            return $p1c,$p1
        }
    }

    $winner,$winnerDeck = Play-SubGame 1 2 $p1 $p2
    Write-Verbose "Player $winner won"

    # calculate the winner's score
    $score = 0
    foreach ($mult in ($winnerDeck.Count..1)) {
        $nextCard = $winnerDeck.Dequeue()
        $score += $nextCard * $mult
    }
    Write-Host $score

}
