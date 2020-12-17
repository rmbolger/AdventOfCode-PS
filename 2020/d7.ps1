[CmdletBinding()]
param(
    [string]$InputFile = '.\d7.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    $reducedInput = Get-Content $InputFile | ForEach-Object {
        $_ -replace ' bag(s)?\.' -replace ' bag(s)?(( contain )|(, ))','|'
    }

    function Get-SelfAndChildren {
        param(
            [string[]]$Color,
            [hashtable]$Rules
        )
        foreach ($c in $Color) {
            $c
            Get-SelfAndChildren $Rules[$c] $Rules
        }
    }


# Part 1
if (-not $NoPart1) {

    # Turn the input into back references where contained colors are the key
    # and the possible parents are the value
    $p1Rules = @{}
    $reducedInput | ForEach-Object {
        $key,[string[]]$vals = $_.Split('|')
        if ($vals[0] -ne 'no other') {
            $vals | ForEach-Object {
                # we don't care about how many, just what color and our
                # input data only uses single digit numbers
                # (val color *can be contained by* key color)
                $p1Rules[$_.Substring(2)] += @($key)
            }
        }
    }

    (Get-SelfAndChildren 'shiny gold' $p1Rules | Select-Object -Unique).Count - 1
}

# Part 2
if (-not $NoPart2) {

    # Make a hashtable from the data largely as-is except multiply the
    # child colors by their count
    $p2rules = @{}
    $reducedInput | ForEach-Object {
        $key,[string[]]$vals = $_.Split('|')
        if ($vals[0] -ne 'no other') {
            $vals | ForEach-Object {
                $num = [int]$_[0].ToString()
                $color = $_.Substring(2)
                $p2rules[$key] += @($color) * $num
            }
        }
    }

    (Get-SelfAndChildren 'shiny gold' $p2rules).Count - 1

}
