[CmdletBinding()]
param(
    [string]$InputFile = '.\d20.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$data = ((Get-Content $InputFile -Raw) -split "`n`n").Trim()
$puzWidth = [Math]::Sqrt($data.Count)
Write-Verbose "$($data.Count) pieces, $puzWidth x $puzWidth puzzle"

function StrRev {
    param([string]$s)
    $a = $s.ToCharArray()
    [array]::Reverse($a)
    [string]::new($a)
}

class Tile {
    [int]$id
    [string]$u
    [string]$r
    [string]$d
    [string]$l
    [string[]]$lines

    Tile ([int]$id,[string[]]$lines) {
        $this.id = $id
        $this.lines = $lines
        $this.u = $lines[0]
        $this.d = $lines[-1]
        $this.l = ($lines | %{ $_[0] }) -join ''
        $this.r = ($lines | %{ $_[-1] }) -join ''
    }

    [string] ToString() {
        return ($this.lines -join "`n")
    }

    [string[]] InnerLines() {
        $inner = 1..($this.lines.Count-2) | %{
            $this.lines[$_].Substring(1,$this.lines[$_].Length-2)
        }
        return $inner
    }

    [bool] IsMatch([string]$side,[Tile]$other) {
        if ($this.$side -in $other.u,$other.d,$other.r,$other.l) { return $true }
        $other.FlipH()
        if ($this.$side -in $other.u,$other.d) { return $true }
        $other.FlipV()
        if ($this.$side -in $other.l,$other.r) { return $true }
        return $false
    }

    [void] FlipH() {
        $this.u = StrRev $this.u
        $this.d = StrRev $this.d
        $this.l,$this.r = $this.r,$this.l
        $this.lines = $this.lines | %{ StrRev $_ }
    }

    [void] FlipV() {
        $this.u,$this.d = $this.d,$this.u
        $this.l = StrRev $this.l
        $this.r = StrRev $this.r
        [array]::Reverse($this.lines)
    }

    [void] Rot90() {
        $this.u,$this.r,$this.d,$this.l = (StrRev $this.l),$this.u,(StrRev $this.r),$this.d
        $newLines = @('') * $this.u.Length
        foreach ($i in (0..($this.lines[0].Length-1))) {
            foreach ($j in (($this.lines.Count-1)..0)) {
                $newLines[$i] += $this.lines[$j][$i]
            }
        }
        $this.lines = $newLines
    }

    [void] Rot180() {
        $this.u,$this.r,$this.d,$this.l = (StrRev $this.d),(StrRev $this.l),(StrRev $this.u),(StrRev $this.r)
        $this.lines = $this.lines | %{ StrRev $_ }
        [array]::Reverse($this.lines)
    }

    [void] Rot270() {
        $this.u,$this.r,$this.d,$this.l = $this.r,(StrRev $this.d),$this.l,(StrRev $this.u)
        $newLines = @('') * $this.u.Length
        foreach ($i in (($this.lines[0].Length-1)..0)) {
            foreach ($j in (0..($this.lines.Count-1))) {
                $newLines[$this.lines[0].Length-1-$i] += $this.lines[$j][$i]
            }
        }
        $this.lines = $newLines
    }

    [Tile] Match([string]$sideVal,[string]$sideDir) {
        # attempt to orient this tile so that the specified side val
        # matches the specified side direction
        if ($sideDir -eq 'u') {
            if ($sideVal -eq $this.u) { return $this }
            if ($sideVal -eq $this.r) {
                $this.Rot270()
                return $this
            }
            if ($sideVal -eq $this.d) {
                $this.FlipV()
                return $this
            }
            if ($sideVal -eq $this.l) {
                $this.FlipV()
                $this.Rot90()
                return $this
            }
            # none of the sides match in the current orientation
            # so flip vertical and re-check left/right
            $this.FlipV()
            if ($sideVal -eq $this.l) {
                $this.FlipV()
                $this.Rot90()
                return $this
            }
            if ($sideVal -eq $this.r) {
                $this.Rot270()
                return $this
            }
            # still nothing, so flip horizontal and re-check up/down
            $this.FlipH()
            if ($sideVal -eq $this.u) { return $this }
            if ($sideVal -eq $this.d) {
                $this.FlipV()
                return $this
            }
        } else { # 'l'
            if ($sideVal -eq $this.u) {
                $this.Rot270()
                $this.FlipV()
                return $this
            }
            if ($sideVal -eq $this.r) {
                $this.FlipH()
                return $this
            }
            if ($sideVal -eq $this.d) {
                $this.Rot90()
                return $this
            }
            if ($sideVal -eq $this.l) { return $this }
            # none of the sides match in the current orientation
            # so flip vertical and re-check left/right
            $this.FlipV()
            if ($sideVal -eq $this.l) { return $this }
            if ($sideVal -eq $this.r) {
                $this.FlipH()
                return $this
            }
            # still nothing, so flip horizontal and re-check up/down
            $this.FlipH()
            if ($sideVal -eq $this.u) {
                $this.Rot270()
                $this.FlipV()
                return $this
            }
            if ($sideVal -eq $this.d) {
                $this.Rot90()
                return $this
            }
        }
        return $null
    }

}

$tiles = $data | %{
    $head,$lines = $_ -split "`n"
    $id = $head.Substring(5,4)
    [Tile]::new($id,$lines)
}

# Part 1
if (-not $NoPart1) {

    # find corners by looking for tiles that have no match on 2 sides
    $cornersFound = 0
    $corners = foreach ($t in $tiles) {
        $missCount = 0

        foreach ($side in 'u','d','l','r') {
            $hasMatch = foreach ($t2 in ($tiles | ?{ $_.id -ne $t.id })) {
                if ($t.IsMatch($side,$t2)) {
                    $true
                    #Write-Verbose "$($t.id).$side matches $($t2.id)"
                    break
                }
            }
            if (-not $hasMatch) {
                $missCount++
            }
        }

        Write-Verbose "$($t.id) side misses $missCount"
        # return it if it's a corner
        if ($missCount -eq 2) {
            $t
            $cornersFound++
        }
        if ($cornersFound -eq 4) { break }
    }

    Write-Verbose "$($corners.Count) tiles with 2 side matches"

    $corners.id | % -Begin { $result = 1 } -Process { $result *= $_ }
    Write-Host $result

}

# Part 2
if (-not $NoPart2) {

    function Get-Roughness {
        param(
            [string]$Habitat,
            [regex]$monster,
            [int]$lg    # line gap, line width minus monster width
        )

        <#
                            #
            #    ##    ##    ###
            #  #  #  #  #  #

            #.............#...#..#...#.......#....#..........#...#..................#.#...###..##.#####..#####....#......#.........#.............##....#........#....#.....#....###...#....#..#..#..#.##..#
            O.............#...#..#...#.......#....#..........#...#..................#.#...O##..OO.###OO..##OOO....#......#.........#.............##....#........#....#.....#....###...#....O..O..O..O.#O..O
            0,78,83,84,89,90,95,96,97,175,178,181,184,187,190
        #>

        # build an array of indices where we will need to replace monster parts with O's
        $lg2 = $lg * 2
        $mIndicies = 0,($lg+2),($lg+7),($lg+8),($lg+13),($lg+14),($lg+19),($lg+20),($lg+21),($lg2+23),($lg2+26),($lg2+29),($lg2+32),($lg2+35),($lg2+38)

        while ($Habitat -match $monster) {
            $m = $matches[0]

            # replace the monster characters with O's
            $mChars = $m.ToCharArray()
            $mIndicies | %{ $mChars[$_] = 'O' }

            # replace this occurrence of the monster with the labeled copy
            $reTemp = [regex]::new([regex]::Escape($m))
            $Habitat = $reTemp.Replace($Habitat, ($mChars -join ''), 1)
        }

        # display the final puzzle in verbose output
        $finalPuzzle = $Habitat -split "(.{$($lg+20)})" | ?{ $_ }
        Write-Verbose "`n$($finalPuzzle -join "`n")"

        # count the waves by stripping . and O characters
        $waves = ($Habitat  -replace '\.|O').Length
        Write-Verbose "waves $waves"
        $waves
    }

    # represent the final puzzle as a 2d array
    $puz = [Tile[][]]::new($puzWidth, $puzWidth)
    # and a flat array of "locked" tile IDs
    $locked = @()
    # and the final puzzle without the tile borders
    $puzInner = @()

    # find a corner and rotate it so it becomes the upper left
    # piece of the puzzle
    Write-Verbose "Searching for first corner"
    foreach ($t in $tiles) {
        $missCount = 0
        $missSides = @()
        foreach ($side in 'u','d','l','r') {
            $hasMatch = foreach ($t2 in ($tiles | ?{ $_.id -ne $t.id })) {
                if ($t.IsMatch($side,$t2)) { $true; break }
            }
            if (-not $hasMatch) {
                $missCount++
                $missSides += $side
            }
        }
        if ($missCount -eq 2) {
            # rotate/flip so that missed sides are oriented upper left
            # u,l - (do nothing)
            # u,r - FlipH
            # d,l - FlipV
            # d,r - FlipH + FlipV (or Rot180)
            if ('r' -in $missSides) { $t.FlipH() }
            if ('d' -in $missSides) { $t.FlipV() }
            # add the tile to the puzzle and lock list
            $puz[0][0] = $t
            $locked += $t.id

            $t.InnerLines() | %{ $puzInner += $_ }
            break
        }
    }

    # find the rest of the pieces
    Write-Verbose "Matching for the rest of the tiles"
    foreach ($y in 0..($puzWidth-1)) {
        foreach ($x in 0..($puzWidth-1)) {

            # skip the upper left because we already got it
            if ($x -eq 0 -and $y -eq 0) { continue }

            # determine which previous tile to match
            if ($x -eq 0) {
                # match the bottom of the tile above
                $sideVal = $puz[$y-1][0].d
                $checkSide = 'u'
            } else {
                # match the right of the tile to the left
                $sideVal = $puz[$y][$x-1].r
                $checkSide = 'l'
            }

            # find the tile that matches the side of our check tile
            foreach ($t in ($tiles | ?{ $_.id -notin $locked })) {
                $tGood = $t.Match($sideVal,$checkSide)
                if ($tGood) {
                    #Write-Verbose "Found tile for $x,$y"
                    $puz[$y][$x] = $tGood
                    $locked += $tGood.id

                    $inner = $tGood.InnerLines()
                    if ($x -eq 0) {
                        $inner | %{ $puzInner += $_ }
                    } else {
                        0..($inner.Count-1) | %{
                            $puzInner[$y*$inner.Count+$_] += $inner[$_]
                        }
                    }
                    break
                }
            }
        }
    }

    # turn the inner puzzle into a big tile we can flip/rotate
    # if necessary
    $bigTile = [Tile]::new(0,$puzInner)

    # create a regex to search for the sea monster in a single
    # line version of the tile
    $spaceBetween = $bigTile.u.Length - 20 # 20 is how wide the monster is
    $reMonster = [regex]"(#)[.O#]{$($spaceBetween+1)}(#)[.O#]{4}(##)[.O#]{4}(##)[.O#]{4}(###)[.O#]{$($spaceBetween+1)}(#)[.O#]{2}(#)[.O#]{2}(#)[.O#]{2}(#)[.O#]{2}(#)[.O#]{2}(#)"
    Write-Verbose $reMonster.ToString()

    $tileFlat = $bigTile.lines -join ''
    $rot = 0
    while ($tileFlat -notmatch $reMonster -and $rot -lt 3) {
        Write-Verbose "monster check failed - rot90"
        $bigTile.Rot90()
        $tileFlat = $bigTile.lines -join ''
        $rot++
    }
    if ($matches -or $tileFlat -match $reMonster) {
        Get-Roughness $tileFlat $reMonster $spaceBetween
        return
    } else {
        Write-Verbose "monster check failed - flipH"
        $bigTile.FlipH()
        $tileFlat = $bigTile.lines -join ''
    }
    $rot = 0
    while ($tileFlat -notmatch $reMonster -and $rot -lt 3) {
        Write-Verbose "monster check failed - rot90"
        $bigTile.Rot90()
        $tileFlat = $bigTile.lines -join ''
        $rot++
    }
    if ($matches -or $tileFlat -match $reMonster) {
        Get-Roughness $tileFlat $reMonster $spaceBetween
        return
    }
    Write-Host 'monster check failed - giving up'
    $bigTile.ToString()

}
