[CmdletBinding()]
param(
    [string]$InputString = '487912365',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$startArray = [int[]]($InputString.ToCharArray() | %{ [int]::Parse($_) })

# Part 1
if (-not $NoPart1) {

    $cups = [Collections.Generic.List[int]]::new($startArray)

    foreach ($turn in (1..100)) {
        $cup = $cups[0]
        $pickup = [int[]]$cups[1..3]
        Write-Verbose "$($cups -join ',') - cup $cup - pickup $($pickup -join ',')"
        $cups.RemoveRange(1,3)

        # find the destination cup and insert the pickup
        $dest = $cup - 1
        while ($dest -notin $cups -or $dest -eq $cup) {
            $dest--
            if ($dest -lt 1) { $dest = 9 }
        }
        $insertAt = $cups.IndexOf($dest) + 1
        $cups.InsertRange($insertAt, $pickup)
        Write-Verbose "dest = $dest (index $($insertAt-1))"

        # move the current cup to the end so the next cup is first
        $cups.RemoveAt(0)
        $cups.Add($cup)
    }

    $finalStart = ($cups.IndexOf(1) + 1) % 9
    ($cups[($finalStart..($finalStart+7) | %{ $_ % 9})]) -join ''

}


# Part 2
if (-not $NoPart2) {

    $startArray = [int[]]($startArray + @(10..1000000))
    $cups = [Collections.Generic.List[int]]::new($startArray)

    foreach ($turn in (1..1000)) {
        $cup = $cups[0]
        $pickup = [int[]]$cups[1..3]
        $cups.RemoveRange(1,3)

        # find the destination cup and insert the pickup
        $dest = $cup - 1
        while ($dest -notin $cups -or $dest -eq $cup) {
            $dest--
            if ($dest -lt 1) { $dest = 1000000 }
        }
        $insertAt = $cups.IndexOf($dest) + 1
        $cups.InsertRange($insertAt, $pickup)
        # if (($turn % 100000) -eq 0) {
        #     Write-Verbose "turn $turn - cup $cup - pickup $($pickup -join ',') - dest = $dest"
        # }

        # move the current cup to the end so the next cup is first
        $cups.RemoveAt(0)
        $cups.Add($cup)
    }

    $finalStart = $cups.IndexOf(1) + 1
    $endCups = $cups[($finalStart..($finalStart+1) | %{ $_ % 1000000})]
    $endCups[0] * $endCups[1]

}
