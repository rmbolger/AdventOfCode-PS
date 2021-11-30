[CmdletBinding()]
param(
    $InputString = '246540-787419',
    [switch]$NoPart2
)

# https://adventofcode.com/2019/day/4

[int]$start,[int]$end = $InputString.Split('-')

# Part 1
$part1Passwords = $start..$end | ForEach-Object {
    $pass = $_
    # convert to array of digits
    $digits = [char[]]$pass.ToString() #| ForEach-Object { $_ - 48 }

    $foundDouble = $false
    for ($i=1; $i -lt $digits.Count; $i++) {
        # disqualify if current digit is less than the previous digit
        if ($digits[$i] -lt $digits[$i-1]) {
            #Write-Verbose "$pass - FAIL $($digits[$i]) -lt $($digits[$i-1])"
            return
        }
        # check for double
        if ($digits[$i] -eq $digits[$i-1]) {
            $foundDouble = $true
        }
    }

    if ($foundDouble) {
        $pass
    } else {
        #Write-Verbose "$pass - FAIL no double"
    }
}
$part1Passwords.Count

# Part 2
if (-not $NoPart2) {
    $part2Passwords = $part1Passwords | ForEach-Object {
        $pass = $_
        # convert to array of characters
        $digits = [char[]]$pass.ToString()

        # group the digits and return only passing groups
        if ($digits | Group-Object | Where-Object {$_.Count -eq 2}) {
            $pass
        }
    }
    $part2Passwords.Count
}
