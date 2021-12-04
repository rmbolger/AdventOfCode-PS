#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d4.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# https://adventofcode.com/2021/day/4

Get-Content $InputFile -Raw | Set-Clipboard

    # pre-calculate sets of winning indexes that represent
    # the winning rows and columns
    $winSets = @(
        ,(0..4)
        ,(5..9)
        ,(10..14)
        ,(15..19)
        ,(20..24)
        ,(0,5,10,15,20)
        ,(1,6,11,16,21)
        ,(2,7,12,17,22)
        ,(3,8,13,18,23)
        ,(4,9,14,19,24)
    )

    # boards are 5x5 but we're going to represent them as a flat array
    $draws,$boards = (gcb) -split "`n`n"
    [int[]]$draws = $draws -split ','
    $boards = $boards | %{
        ,[int[]]($_ -split "[\s]" | ?{$_})
    }

    # use the "win" set indexes to calculate the sets of winning draws
    # for each board
    $boardWins = $boards | %{
        $b=$_
        $wins = $winSets | %{ ,$b[$_] }
        ,$wins
    }

# Part 1 - runtime ~1s
if (-not $NoPart1) {

    # start at the 5th draw which is the first possible winner
    for ($i=4; $i -lt $draws.Count; $i++) {

        # get the set of numbers drawn so far
        $curDraws = $draws[0..$i]

        # check the boards for wins
        $score = for ($j=0; $j -lt $boards.Count; $j++) {

            if ($boardWins[$j] | Where-Object {
                # compare the numbers drawn to the set required for winning
                # when 5 match, it's a win
                (Compare-Object $_ $curDraws -ExcludeDifferent).Count -eq 5
            }) {
                # calculate and return the score
                $boardScore = ($boards[$j] | ?{ $_ -notin $curDraws }) -join '+' | iex
                $boardScore * $draws[$i]
                break
            }
        }

        if ($score) {
            $score
            break
        }
    }

}

# Part 2 - runtime ~6s
if (-not $NoPart2) {

    # create a list of not-yet-won board IDs that we'll remove from
    # as boards win
    $idsLeft = 0..($boards.Count-1)

    # start at the 5th draw which is the first possible winner
    for ($i=4; $i -lt $draws.Count; $i++) {

        # get the set of numbers drawn so far
        $curDraws = $draws[0..$i]

        # find the non-winning boards
        $nonWinners = @($idsLeft | Where-Object {
            $winner = $boardWins[$_] | Where-Object {
                (Compare-Object $_ $curDraws -ExcludeDifferent).Count -eq 5
            }
            if (-not $winner) { $true }
        })

        if ($nonWinners) {
            # keep drawing
            #Write-Verbose "$($nonWinners.Count) board(s) remaining"
            $idsLeft = $nonWinners
            continue
        }
        else {
            # return the score
            $boardScore = ($boards[$idsLeft[0]] | ?{$_ -notin $curDraws}) -join '+' | iex
            #Write-Verbose "last board ID $($idsLeft[0]) - score $boardScore - draw $($draws[$i])"
            $boardScore * $draws[$i]
            break
        }
    }

}
