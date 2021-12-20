#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d19.txt',
    [switch]$Part2
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

# Add a "hash" value to each pair of signals in a scanner that uniquely
# identifies their positional relationship to each other
# So signals[0].hashes[1] will be equivalent to signals[1].hashes[0].
foreach ($scanner in $scanners) {
    foreach ($sig in $scanner.signals) {
        $others = $scanner.signals | ?{ $_.id -ne $sig.id }
        foreach ($sigAlt in $others) {
            $dx = [Math]::Abs($sig.x-$sigAlt.x)
            $dy = [Math]::Abs($sig.y-$sigAlt.y)
            $dz = [Math]::Abs($sig.z-$sigAlt.z)
            $distVal = $dx*$dx+$dy*$dy+$dz*$dz
            $deltas = [int[]]@($dx,$dy,$dz)
            $hash = '{0},{1},{2}' -f $distVal,[Linq.Enumerable]::Min($deltas),[Linq.Enumerable]::Max($deltas)
            $sig.hashes[$sigAlt.id] = $sigAlt.hashes[$sig.id] = $hash
            #Write-Verbose "hash sig$($sig.id)/$($sigAlt.id) = $hash"
        }
    }
}

function Compare-Signal {
    [CmdletBinding()]
    param(
        [hashtable]$SignalA,
        [hashtable]$SignalB
    )

    $result = foreach ($kvA in $SignalA.hashes.GetEnumerator()) {
        $kvB = $SignalB.hashes.GetEnumerator() | ?{ $_.Value -eq $kvA.Value }
        if ($kvB.Count -gt 0) {
            #Write-Verbose "    sig match between signals $($kvA.Key) and $($kvB.Key) ($($SignalB.hashes[$kvB.Key]))"
            @{
                hash = $SignalB.hashes[$kvB.Key]
                idA = $kvA.Key
                idB = $kvB.Key
            }
        }
    }
    return $result
}

function Compare-Scanner {
    [CmdletBinding()]
    param(
        [PSObject]$ScannerA,
        [PSObject]$ScannerB
    )

    foreach ($sigThere in $ScannerB.signals) {
        foreach ($sigHere in $ScannerA.signals) {
            $sigMatches = Compare-Signal $sigHere $sigThere
            if ($sigMatches.Count -ge 11) {
                Write-Verbose "compare scan($($ScannerA.id)).sig($($sigHere.id)) to scan($($ScannerB.id)).sig($($sigThere.id))"
                return @{
                    sigHere = $sigHere
                    sigThere = $sigThere
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

        $relHere = $ScannerA.signals[$sm.idA]
        $dx0 = $ScanMatch.sigHere.x - $relHere.x
        $dy0 = $ScanMatch.sigHere.y - $relHere.y
        $dz0 = $ScanMatch.sigHere.z - $relHere.z

        $relThere = $ScannerB.signals[$sm.idB]
        $dx1 = $ScanMatch.sigThere.x - $relThere.x
        $dy1 = $ScanMatch.sigThere.y - $relThere.y
        $dz1 = $ScanMatch.sigThere.z - $relThere.z

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
            x = $ScanMatch.sigHere.x - $ScanMatch.sigThere.x
            y = $ScanMatch.sigHere.y - $ScanMatch.sigThere.y
            z = $ScanMatch.sigHere.z - $ScanMatch.sigThere.z
        }
        Write-Verbose "    Scanner $($ScannerB.id) position $($ScannerB.position.x),$($ScannerB.position.y),$($ScannerB.position.z)"

        foreach ($sig in $ScannerB.signals) {
            $sig.x += $ScannerB.position.x
            $sig.y += $ScannerB.position.y
            $sig.z += $ScannerB.position.z
        }

        break
    }
}

# set the first scanner's position to 0,0,0
$scanners[0].position = @{x=0;y=0;z=0}

$locked = [Collections.Generic.HashSet[int]]::new()
$null = $locked.Add(0)
while ($locked.Count -lt $scanners.Count) {
    for ($i=0; $i -lt $scanners.Count; $i++) {
        for ($j=0; $j -lt $scanners.Count; $j++) {
            if ($i -eq $j -or !$locked.Contains($i) -or $locked.Contains($j)) {
                continue
            }
            Write-Verbose "compare scanner $i and $j"
            $scanMatch = Compare-Scanner $scanners[$i] $scanners[$j]
            if (-not $scanMatch) { continue }

            Invoke-ScannerAlign $scanners[$i] $scanners[$j] $scanMatch

            $null = $locked.Add($j)
        }
    }
}

$allBeacons = $scanners | %{ $_.signals | %{ [pscustomobject]$_ } }
$beacons = $allBeacons | sort -unique x,y,z
Write-Host "Part 1: $($beacons.Count)"

$distances = foreach ($here in $scanners) {
    foreach ($there in $scanners) {
        $xdiff = [Math]::Abs($there.position.x - $here.position.x)
        $ydiff = [Math]::Abs($there.position.y - $here.position.y)
        $zdiff = [Math]::Abs($there.position.z - $here.position.z)
        $xdiff + $ydiff + $zdiff
    }
}
$maxDist = $distances | sort -desc | select -first 1
Write-Host "Part 2: $maxDist"
