#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d19.txt'
)

# https://adventofcode.com/2021/day/19

$data = Get-Content $InputFile -Raw
Set-Clipboard $data

    # parse the input into a list of scanners that each have
    # a list of signals
    $scanners = foreach ($scanRaw in ((Get-Clipboard -Raw) -split "`n`n")) {
        $sigLines = $scanRaw.Trim() -split "`n" | Select-Object -Skip 1
        $sigID = 0
        $signals = foreach ($line in $sigLines) {
            [int]$x,[int]$y,[int]$z = $line -split ','
            @{
                id = $sigID
                x = $x
                y = $y
                z = $z
                hashes = @{}
            }
            $sigID++
        }
        [pscustomobject]@{
            id = [int]$scanID
            signals = $signals
            position = $null
        }

        $scanID++
    }

    # Add a "hash" value for each pair of unique signals in a scanner that
    # identifies their positional relationship to each other
    # So signals[0].hashes[<hash>] will be the id of the other signal.
    foreach ($scanner in $scanners) {
        for ($i=0; $i -lt $scanner.signals.Count; $i++) {
            for ($j=$i+1; $j -lt $scanner.signals.Count; $j++) {
                $sig = $scanner.signals[$i]
                $sigAlt = $scanner.signals[$j]
                $dx = [Math]::Abs($sig.x-$sigAlt.x)
                $dy = [Math]::Abs($sig.y-$sigAlt.y)
                $dz = [Math]::Abs($sig.z-$sigAlt.z)
                $distVal = $dx*$dx+$dy*$dy+$dz*$dz  # Math.Sqrt not necessary for uniqueness
                $deltas = [int[]]@($dx,$dy,$dz)
                $hash = '{0},{1},{2}' -f $distVal,[Linq.Enumerable]::Min($deltas),[Linq.Enumerable]::Max($deltas)
                $sig.hashes[$hash] = $sigAlt.id
                $sigAlt.hashes[$hash] = $sig.id
            }
        }
    }

    function Compare-Scanner {
        [CmdletBinding()]
        param(
            [PSObject]$ScannerA,
            [PSObject]$ScannerB
        )
        #Write-Verbose "compare scanner $($ScannerA.id) and $($ScannerB.id)"

        foreach ($sigB in $ScannerB.signals) {
            foreach ($sigA in $ScannerA.signals) {

                # check for hash matches between these two signals
                [string[]]$sigAHashes = $sigA.hashes.Keys
                [string[]]$sigBHashes = $sigB.hashes.Keys
                $sigMatches = [Linq.Enumerable]::Intersect($sigAHashes,$sigBHashes) | %{
                    @{
                        hash = $_
                        idA = $sigA.hashes[$_]
                        idB = $sigB.hashes[$_]
                    }
                }

                if ($sigMatches.Count -ge 11) {
                    Write-Verbose "Matched scan($($ScannerA.id)).sig($($sigA.id)) to scan($($ScannerB.id)).sig($($sigB.id))"
                    return @{
                        sigA = $sigA
                        sigB = $sigB
                        sigMatches = $sigMatches
                    }
                }
            }
        }
    }

    function Invoke-ScannerAlign {
        [CmdletBinding()]
        param(
            [PSObject]$ScannerA,
            [PSObject]$ScannerB,
            [hashtable]$ScanMatch
        )

        foreach ($sm in $ScanMatch.sigMatches) {

            $dist,$minDelta,$maxDelta = $sm.hash -split ','
            if ($minDelta -eq 0) { continue }

            $relA = $ScannerA.signals[$sm.idA]
            $dx0 = $ScanMatch.sigA.x - $relA.x
            $dy0 = $ScanMatch.sigA.y - $relA.y
            $dz0 = $ScanMatch.sigA.z - $relA.z

            $relB = $ScannerB.signals[$sm.idB]
            $dx1 = $ScanMatch.sigB.x - $relB.x
            $dy1 = $ScanMatch.sigB.y - $relB.y
            $dz1 = $ScanMatch.sigB.z - $relB.z

            if ([Math]::Abs($dx0) -eq [Math]::Abs($dy0) -or
                [Math]::Abs($dz0) -eq [Math]::Abs($dy0) -or
                [Math]::Abs($dx0) -eq [Math]::Abs($dz0))
            {
                continue
            }

            $map = 0,0,0,0,0,0,0,0,0
            if ($dx0 -eq $dx1) {
                $map[0] = 1
            } elseif ($dx0 -eq -$dx1) {
                $map[0] = -1
            }
            if ($dx0 -eq $dy1) {
                $map[3] = 1
            } elseif ($dx0 -eq -$dy1) {
                $map[3] = -1
            }
            if ($dx0 -eq $dz1) {
                $map[6] = 1
            } elseif ($dx0 -eq -$dz1) {
                $map[6] = -1
            }
            if ($dy0 -eq $dx1) {
                $map[1] = 1
            } elseif ($dy0 -eq -$dx1) {
                $map[1] = -1
            }
            if ($dy0 -eq $dy1) {
                $map[4] = 1
            } elseif ($dy0 -eq -$dy1) {
                $map[4] = -1
            }
            if ($dy0 -eq $dz1) {
                $map[7] = 1
            } elseif ($dy0 -eq -$dz1) {
                $map[7] = -1
            }
            if ($dz0 -eq $dx1) {
                $map[2] = 1
            } elseif ($dz0 -eq -$dx1) {
                $map[2] = -1
            }
            if ($dz0 -eq $dy1) {
                $map[5] = 1
            } elseif ($dz0 -eq -$dy1) {
                $map[5] = -1
            }
            if ($dz0 -eq $dz1) {
                $map[8] = 1
            } elseif ($dz0 -eq -$dz1) {
                $map[8] = -1
            }

            foreach ($sig in $ScannerB.signals) {
                $oldX = $sig.x
                $oldY = $sig.y
                $oldZ = $sig.z
                $sig.x = $oldX * $map[0] + $oldY * $map[3] + $oldZ * $map[6]
                $sig.y = $oldX * $map[1] + $oldY * $map[4] + $oldZ * $map[7]
                $sig.z = $oldX * $map[2] + $oldY * $map[5] + $oldZ * $map[8]
            }

            $ScannerB.position = @{
                x = $ScanMatch.sigA.x - $ScanMatch.sigB.x
                y = $ScanMatch.sigA.y - $ScanMatch.sigB.y
                z = $ScanMatch.sigA.z - $ScanMatch.sigB.z
            }
            Write-Verbose "Scanner $($ScannerB.id) position $($ScannerB.position.x),$($ScannerB.position.y),$($ScannerB.position.z)"

            foreach ($sig in $ScannerB.signals) {
                $sig.x += $ScannerB.position.x
                $sig.y += $ScannerB.position.y
                $sig.z += $ScannerB.position.z
            }

            break
        }
    }

    $locked = [Collections.Generic.HashSet[int]]::new()
    $pairsChecked = [Collections.Generic.HashSet[string]]::new()

    # set the first scanner's position to 0,0,0
    $scanners[0].position = @{x=0;y=0;z=0}
    $null = $locked.Add(0)

    while ($locked.Count -lt $scanners.Count) {         # loop until all locked

        for ($i=0; $i -lt $scanners.Count; $i++) {
            for ($j=1; $j -lt $scanners.Count; $j++) {

                # skip pairs that don't make sense
                $pairKey = '{0},{1}' -f $i,$j
                if ($i -eq $j -or                       # don't check same scanner
                    !$locked.Contains($i) -or           # don't use an unlocked primary
                    $locked.Contains($j) -or            # don't use a locked secondary
                    $pairsChecked.Contains($pairKey)    # don't re-check a combo
                ) {
                    continue
                }

                # prevent re-checks
                $null = $pairsChecked.Add($pairKey)

                # align and lock if matched
                if ($scanMatch = Compare-Scanner $scanners[$i] $scanners[$j]) {
                    Invoke-ScannerAlign $scanners[$i] $scanners[$j] $scanMatch
                    $null = $locked.Add($j)
                }
            }
        }
    }

    $allBeacons = $scanners | %{ $_.signals | %{ [pscustomobject]$_ } }
    $beacons = $allBeacons | Sort-Object -Unique x,y,z
    Write-Host "Part 1: $($beacons.Count)"

    $distances = foreach ($here in $scanners) {
        foreach ($there in $scanners) {
            $xdiff = [Math]::Abs($there.position.x - $here.position.x)
            $ydiff = [Math]::Abs($there.position.y - $here.position.y)
            $zdiff = [Math]::Abs($there.position.z - $here.position.z)
            $xdiff + $ydiff + $zdiff
        }
    }
    $maxDist = $distances | Sort-Object -desc | Select-Object -first 1
    Write-Host "Part 2: $maxDist"
