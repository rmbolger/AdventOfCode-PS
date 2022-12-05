#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d5.txt'
)

# https://adventofcode.com/2022/day/4

    # Shared Prep

    $stacksRaw,$movesRaw = (Get-Content $InputFile -Raw) -split "`n`n"
    $stackLines = $stacksRaw -split "`n"
    $moves = $movesRaw.Trim() -split "`n"

    # calculate the char positions for each stack from line length
    $posNums = 0..([Math]::Floor($stackLines[0].Length/4)) | %{ $_*4+1 }
    $stackNums = 1..$posNums.Count

    # create a hashtable of stacks where the key is the stack number
    $stacks1 = @{}
    $stackNums | ForEach-Object {
        $stacks1[$_] = [Collections.Generic.Stack[char]]::new()
    }

    # parse the stack diagram starting from the bottom row of letters
    # so we can add the crates to the actual Stack objects correctly
    for ($i=($stackLines.Count-2); $i -ge 0; $i--) {
        $stackNum=0
        $posNums | ForEach-Object {
            $stackNum++
            $c = $stackLines[$i][$_]
            if ($c -ne ' ') {
                $stacks1[$stackNum].Push($stackLines[$i][$_])
            }
        }
    }

    # clone our unmolested stacks for part 2 so we don't have to re-parse
    $stacks2 = @{}
    $stackNums | ForEach-Object {
        $arr = $stacks1[$_].ToArray()
        [array]::Reverse($arr)
        $stacks2[$_] = [Collections.Generic.Stack[char]]::new($arr)
    }

    # Part 1: Run through all the moves to manipulate the stacks
    $moves | ForEach-Object {

        $null,$count,$from,$to = $_ -split '\D+' -as [int[]]
        for ($i=0; $i -lt $count; $i++) {
            $stacks1[$to].Push($stacks1[$from].Pop())
        }

    }
    ($stackNums | ForEach-Object { $stacks1[$_].Peek() }) -join ''

    # Part 2: Run through all the moves to manipulate the stacks
    $moves | ForEach-Object {

        $null,$count,$from,$to = $_ -split '\D+' -as [int[]]
        $crates = for ($i=0; $i -lt $count; $i++) {
            $stacks2[$from].Pop()
        }
        [array]::Reverse($crates)
        for ($i=0; $i -lt $count; $i++) {
            $stacks2[$to].Push($crates[$i])
        }

    }
    ($stackNums | ForEach-Object { $stacks2[$_].Peek() }) -join ''
