#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d2.txt'
)

# https://adventofcode.com/2022/day/2

# Opponent first column
#     A = Rock
#     B = Paper
#     C = Scissors
# outcome points
#    0 = lose
#    3 = draw
#    6 = win

# round score = your shape + outcome points
# total score = sum of round scores

    # Part 1

    # Second column
    #     X = Rock      (score 1)
    #     Y = Paper     (score 2)
    #     Z = Scissors  (score 3)

    # make a simple lookup table for all potential outcomes
    $outcomes = @{
        'A X' = 4 #     rock(1) draws(3) to rock
        'A Y' = 8 #    paper(2)  wins(6) to rock
        'A Z' = 3 # scissors(3) loses(0) to rock
        'B X' = 1 #     rock(1) loses(0) to paper
        'B Y' = 5 #    paper(2) draws(3) to paper
        'B Z' = 9 # scissors(3)  wins(6) to paper
        'C X' = 7 #     rock(1)  wins(6) to scissors
        'C Y' = 2 #    paper(2) loses(0) to scissors
        'C Z' = 6 # scissors(3) draws(3) to scissors
    }

    Get-Content $InputFile
    | ForEach-Object { $outcomes[$_] }
    | Measure-Object -Sum
    | Select-Object -Expand Sum

    # Part 2

    # Second column
    #    X = Lose   (score 0)
    #    Y = Draw   (score 3)
    #    Z = Win    (score 6)

    $outcomes = @{
        'A X' = 3 # scissors(3) loses(0) to rock
        'A Y' = 4 #     rock(1) draws(3) to rock
        'A Z' = 8 #    paper(2)  wins(6) to rock
        'B X' = 1 #     rock(1) loses(0) to paper
        'B Y' = 5 #    paper(2) draws(3) to paper
        'B Z' = 9 # scissors(3)  wins(6) to paper
        'C X' = 2 #    paper(2) loses(0) to scissors
        'C Y' = 6 # scissors(3) draws(3) to scissors
        'C Z' = 7 #     rock(1)  wins(6) to scissors
    }

    Get-Content $InputFile
    | ForEach-Object { $outcomes[$_] }
    | Measure-Object -Sum
    | Select-Object -Expand Sum
