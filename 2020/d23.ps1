[CmdletBinding()]
param(
    [string]$InputString = '487912365',
    [switch]$NoPart1,
    [switch]$NoPart2
)

function Run-CupGame {
    [CmdletBinding()]
    param(
        [int[]]$StartArray,
        [int]$Turns,
        [switch]$Part2
    )

    # build the cups linked list and store a reference to each node in a
    # dictionary for quick lookups by value later
    if ($Part2) {
        $StartArray = [int[]]($StartArray + @(10..1000000))
    }
    $cupCount = ($Part2) ? 1000000 : 9
    $cups = [Collections.Generic.LinkedList[int]]::new($StartArray)
    $cupmap = [Collections.Generic.Dictionary[int,Collections.Generic.LinkedListNode[int]]]::new($cupCount)
    $c = $cups.First
    while ($c) {
        $cupmap[$c.Value] = $c
        $c = $c.Next
    }

    foreach ($turn in (1..$Turns)) {
        $cup = $cups.First
        $p1 = $cup.Next
        $p2 = $p1.Next
        $p3 = $p2.Next
        $cups.Remove($p1)
        $cups.Remove($p2)
        $cups.Remove($p3)

        # find the destination value
        $dest = $cup.Value
        do {
            $dest--
            if ($dest -lt 1) { $dest = $cupCount }
        }
        while ($dest -eq $p1.Value -or $dest -eq $p2.Value -or $dest -eq $p3.Value)

        # lookup the cup reference and insert the pickups
        $destCup = $cupmap.$dest
        $cups.AddAfter($destCup, $p3)
        $cups.AddAfter($destCup, $p2)
        $cups.AddAfter($destCup, $p1)
        # if (($turn % 100000) -eq 0) {
        #     Write-Verbose "turn $turn - cup $($cup.Value) - pickup $(($pickup | %{ $_.Value }) -join ',') - dest = $($destCup.Value)"
        # }

        # move the current cup to the end so the next cup is first
        [void] $cups.RemoveFirst()
        [void] $cups.AddLast($cup)
    }

    if (-not $Part2) {
        # return part 1 results
        $parts = $cups -join '' -split '1'
        return "$($parts[1])$($parts[0])"
    }
    else {
        # return part 2 results
        $cup1 = $cupmap[1]
        $cupN = $cup1.Next
        if (-not $cupN) {
            $cupN = $cups.First
            $cupNN = $cups.First.Next
        } else {
            $cupNN = $cupN.Next
            if (-not $cupNN) { $cupNN = $cups.First }
        }
        return ($cupN.Value * $cupNN.Value)
    }
}

$startArray = [int[]]($InputString.ToCharArray() | %{ [int]::Parse($_) })

# Part 1
if (-not $NoPart1) {

    $result = Run-CupGame $startArray 100
    Write-Host $result

}


# Part 2
if (-not $NoPart2) {

    $result = Run-CupGame $startArray 10000000 -Part2
    Write-Host $result

}
