[CmdletBinding()]
param(
    [string]$InputFile = '.\d16.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$data = ((Get-Content $InputFile -Raw) -split "`n`n").Trim()

# save the rules in a hashtable of scriptblocks
$rules = @{}
$reRule = [regex]'(?<rule>[a-z ]+): (?<n1>\d+)-(?<n2>\d+) or (?<n3>\d+)-(?<n4>\d+)'
$data[0] -split "`n" | ForEach-Object {
    if ($_ -match $reRule) {
        $rules[$matches.rule] = @"
            { param([int[]]`$vals)
            foreach (`$x in `$vals) {
                (`$x -ge $($matches.n1) -and `$x -le $($matches.n2)) -or
                (`$x -ge $($matches.n3) -and `$x -le $($matches.n4))
            }
            }
"@ | iex
    }
    else { Write-Warning "No rule match: $_" }
}

# parse my ticket
$myticket = ($data[1] -split "`n" | Select-Object -Skip 1).Split(',')

# partially parse the nearby tickets so we can get the count
$nearbyStrings = $data[2] -split "`n" | Select-Object -Skip 1

# save the nearby ticket numbers into a 2d array *by column*
# so all of the first numbers are index 0, second numbers are index 1, etc.
$rowMax = $myticket.Count - 1
$colMax = $nearbyStrings.Count
$tickets = [int[][]]::new($rowMax+1, $colMax+1)

# add my ticket first
0..$rowMax | %{ $tickets[$_][0] = $myticket[$_] }
# add the rest
foreach ($col in (1..$colMax)) {
    $nums = $nearbyStrings[$col-1].Split(',')
    foreach ($row in (0..$rowMax)) {
        $tickets[$row][$col] = $nums[$row]
    }
}


# Part 1
if (-not $NoPart1) {

    # find any ticket numbers (except ours) that don't fit any rule
    # and save the ticket index so we know which ones to skip for part 2
    $badTickets = [Collections.Generic.HashSet[int]]::new()
    $badNums = foreach ($i in (0..$rowMax)) {
        foreach ($j in (1..$colMax)) {
            $num = $tickets[$i][$j]
            $results = $rules.Values | ForEach-Object {
                &$_ $num
            }
            if ($true -notin $results) {
                $num
                [void] $badTickets.Add($j)
            }
        }
    }
    Write-Host ($badNums | measure -sum).Sum

}


# Part 2
if (-not $NoPart2) {

    # use $badTickets from part 1 to get a list of good ticket indexes
    $goodTickets = 0..$colMax | ?{ $_ -notin $badTickets }

    # create a hashtable and store the ticket number indexes that correspond
    # to each rule we figure out
    $ruleIndices = @{}
    foreach ($i in (0..$rowMax)) {
        foreach ($name in $rules.Keys) {
            # invoke the rule's scriptblock with the numbers in this
            # column from the good tickets
            $results = &$rules.$name $tickets[$i][$goodTickets]
            if ($false -notin $results) {
                # all of the good tickets match this rule for this index
                #Write-Verbose "all numbers at index $i match rule $name"
                $ruleIndices.$name += ,$i
            }
        }
    }

    # Each rule theoretically now has 1 or more "good" indices associated
    # with it that we need to narrow down so that there's only one for each.
    # Find the rule with only one index and remove that index from the options
    # for the rest, then repeat until all rules only have 1 good index..
    # (This assumes "nice" data where there will always be only 1 option
    # with one index at a time.)
    $final = @{}
    0..$rowMax | ForEach-Object {
        # find the rule with one index
        $rule = $ruleIndices.GetEnumerator() | ?{ $_.Value.Count -eq 1 }
        # add it to the final list
        $final[$rule.Name] = $rule.Value[0]
        # remove it from the list to check
        $ruleIndices.Remove($rule.Name)
        # remove the index from the rules left to check
        foreach ($key in $($ruleIndices.Keys)) {
            $ruleIndices.$key = $ruleIndices.$key | ?{ $_ -ne $rule.Value[0] }
        }
    }

    # find the values from our ticket associated with all of the 'departure'
    # rules and multiple them together.
    # (this will be 1 for the sample data since there are no departure rules)
    $final.Keys | ?{ $_ -like 'departure*' } | ForEach-Object -Begin { $val = 1 } -Process {
        #Write-Verbose "$_ is index $($final.$_) -> $($tickets[$final.$_][0])"
        $val *= $tickets[$final.$_][0]
    }
    Write-Host $val

}
