#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d14.txt'
)

# https://adventofcode.com/2021/day/14

$data = Get-Content $InputFile
Set-Clipboard $data

    $poly,$insertsRaw = Get-Clipboard | Where-Object {$_}

    # build the lookup table for pair insertions
    $inserts = @{}
    switch -Regex ($insertsRaw) {
        '(\w+) -> (\w)' {
            $inserts[$matches[1]] = [pscustomobject]@{
                # the char to insert
                char = $matches[2]
                # the child pairs
                children = @(
                    "$($matches[1][0])$($matches[2])"
                    "$($matches[2])$($matches[1][1])"
                )
            }
        }
    }

    # initialize hashtables for character and pair counts
    $charCounts = @{}
    $pairCounts = @{}
    for ($i=0; $i -lt ($poly.Length-1); $i++) {
        $chars = [string[]]$poly[$i..($i+1)]
        $charCounts[$chars[0]] += 1
        $pairCounts[($chars -join '')] += 1
    }
    $charCounts[[string]$poly[-1]] += 1

    1..40 | ForEach-Object {

        # clone the current pair counts and reset the hashtable
        $oldPairs = $pairCounts.GetEnumerator() | %{ [pscustomobject]@{key=$_.Key;count=$_.Value} }
        $pairCounts = @{}

        $oldPairs | ForEach-Object {
            # grab the pair insertion data
            $ins = $inserts[$_.key]

            # increment the counter for the inserted char
            # by the number of parents
            $charCounts[$ins.char] += $_.count

            # increment the pair counts for each new child pair
            # by the number of parents
            $pairCounts[$ins.children[0]] += $_.count
            $pairCounts[$ins.children[1]] += $_.count
        }

        # output on step 10 for part 1
        if ($_ -eq 10) {
            $counts = $charCounts.GetEnumerator() | Sort-Object Value | % Value
            Write-Host "Part 1: $($counts[-1] - $counts[0])"
        }
    }

    # output for part 2
    $counts = $charCounts.GetEnumerator() | Sort-Object Value | % Value
    Write-Host "Part 2: $($counts[-1] - $counts[0])"
