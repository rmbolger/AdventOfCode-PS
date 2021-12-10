#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d10.txt',
    [switch]$NoPart2
)

# https://adventofcode.com/2021/day/10

$data = Get-Content $InputFile
Set-Clipboard $data

# Part 1 & 2 Combined

    $stk = [Collections.Generic.Stack[string]]::new()

    $p1Points = @{
        ')' = 3
        ']' = 57
        '}' = 1197
        '>' = 25137
    }
    $p2Points = @{
        ')' = 1
        ']' = 2
        '}' = 3
        '>' = 4
    }
    $endMatches = @{
        '(' = ')'
        '[' = ']'
        '{' = '}'
        '<' = '>'
    }

    $p2Scores = gcb | %{

        # initialize the stack and score for this line
        $stk.Clear()
        $score = 0
        #Write-Verbose "$_"

        # loop through the characters
        foreach ($c in ([string[]]$_.ToCharArray())) {
            # grab a copy of the last entry
            $last = ($stk.Count -gt 0) ? $stk.Peek() : $null

            switch -Regex ($c) {
                '[[{(<]' {
                    # add this opener to the stack
                    $stk.Push($c)
                    break
                }
                '[\]})>]' {
                    # check if this closer matches the last opener
                    if ($endMatches[$last] -ne $c) {
                        #Write-Verbose "    corrupt $c = $($p1Points[$c]), last $last"
                        # score the corrupt character and go to the next line
                        $p1Score += $p1Points[$c]
                        return
                    }
                    # pop its matching opener off the stack
                    $null = $stk.Pop()
                    break
                }
            }
        }

        # If we're here, the sequence is incomplete.
        # Complete the sequence while incrementing the score
        while ($stk.Count -gt 0) {
            $score *= 5
            $score += $p2Points[$endMatches[$stk.Pop()]]
        }
        # throw it on the pipeline
        $score
    }

    # Part 1
    $p1Score

    # Part 2 - find the median score (always odd count)
    $p2Scores | Sort-Object | Select-Object -Skip (($p2Scores.Count-1)/2) -First 1
