#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d3.txt'
)

# https://adventofcode.com/2022/day/3

    # Part 1 and 2

    function ConvertTo-Priority {
        param([char]$char)

        # ASCII char values
        # A-Z = 65-90  (subtract 38 for priority)
        # a-z = 97-122 (subtract 96 for priority)
        $byte = [byte]$char

        ($byte -le 90) ? ($byte-38) : ($byte-96)
    }

    function Get-CommonPriority {
        param([char[]]$items)

        $half = $items.Count/2
        $comp1 = $items[0..($half-1)]
        $comp2 = $items[$half..($items.Count-1)]
        $shared = $comp1
        | Where-Object { $_ -cin $comp2 }
        | Select-Object -First 1

        ConvertTo-Priority $shared
    }

    $sacks = Get-Content $InputFile
    $p1Sum = $p2Sum = 0

    for ($i=0; $i -lt $sacks.Count; $i+=3) {

        $items1 = $sacks[$i].ToCharArray()
        $items2 = $sacks[$i+1].ToCharArray()
        $items3 = $sacks[$i+2].ToCharArray()

        $p1Sum += Get-CommonPriority $items1
        $p1Sum += Get-CommonPriority $items2
        $p1Sum += Get-CommonPriority $items3

        $badge = $items1
        | Where-Object { $_ -cin $items2 -and $_ -cin $items3 }
        | Select-Object -First 1

        $p2Sum += ConvertTo-Priority $badge
    }

    $p1Sum
    $p2Sum
