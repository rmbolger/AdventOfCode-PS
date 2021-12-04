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

# runtime - 31s
if (-not $NoPart1) {

    # boards are 5x5 but we're going to represent them as a flat array
    $draws,$boards = (gcb) -split "`n`n"
    [int[]]$draws = $draws -split ','
    $boards = $boards | %{
        ,[int[]]($_ -split "[\s]" | ?{$_})
    }

    $drawCount = 0
    foreach ($draw in $draws) {
        $drawCount++

        $score = foreach ($b in $boards) {  # loop through the boards

            # mark each one by replacing the matching number with -1
            0..24 | %{
                if ($b[$_] -eq $draw) { $b[$_] = -1 }
            }
            #Write-Verbose "$draw : $($b -join ',')"

            # don't worry about winners until there's at least 5 draws
            if ($drawCount -lt 5) { continue }

            # check if it's a winner
            $winner = foreach ($set in $winSets) {
                if (($b[$set] -join '+' | iex) -eq -5) {
                    $true
                    break
                }
                # else { Write-Verbose "    $($_ -join ',') : $($b[$_] -join '+')" }
            }

            # return the score if it's a winner
            if ($winner) {
                $boardScore = ($b | ?{$_ -gt 0}) -join '+' | iex
                $boardScore * $draw
                break
            }
        }

        if ($score) {
            $score
            break
        }

    }
}

# runtime - 65s
if (-not $NoPart2) {

    # boards are 5x5 but we're going to represent them as a flat array
    $draws,$boards = (gcb) -split "`n`n"
    [int[]]$draws = $draws -split ','
    $boards = $boards | %{
        ,[int[]]($_ -split "[\s]" | ?{$_})
    }

    $drawCount = 0
    foreach ($draw in $draws) {
        $drawCount++

        # mark each board
        (0..24).foreach({
            $i = $_
            $boards.foreach({
                if ($_[$i] -eq $draw) { $_[$i] = -1 }
            })
        })
        #$boards | %{ Write-Verbose "$draw : $($_ -join ',')" }

        # don't worry about winners until there's at least 5 draws
        if ($drawCount -lt 5) { continue }

        # find non-winning board(s)
        $nonWinners = $boards.where({
            $b = $_
            $winner = foreach ($set in $winSets) {
                if (($b[$set] -join '+' | iex) -eq -5) {
                    $true
                    break
                }
            }
            if (-not $winner) { return $true }
        })

        if ($nonWinners) {
            # keep drawing
            #Write-Verbose "$($nonWinners.Count) board(s) remaining"
            $boards = $nonWinners
            continue
        }
        else {
            # return the score
            $boardScore = ($boards[0] | ?{$_ -gt 0}) -join '+' | iex
            #Write-Verbose "score $boardScore - draw $draw"
            $boardScore * $draw
            break
        }
    }

}
