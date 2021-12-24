#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d22.txt'
)

# https://adventofcode.com/2021/day/22

$data = Get-Content $InputFile
Set-Clipboard $data

class Cuboid {
    [int]$x0
    [int]$x1
    [int]$y0
    [int]$y1
    [int]$z0
    [int]$z1

    Cuboid([int]$x0,[int]$x1,[int]$y0,[int]$y1,[int]$z0,[int]$z1) {
        $this.x0 = $x0
        $this.x1 = $x1
        $this.y0 = $y0
        $this.y1 = $y1
        $this.z0 = $z0
        $this.z1 = $z1
    }

    [string]ToString() {
        return '({0}..{1}),({2}..{3}),({4}..{5})' -f $this.x0,$this.x1,$this.y0,$this.y1,$this.z0,$this.z1
    }
    [string]ToStringDim() {
        return '{0},{1},{2}' -f ($this.x1-$this.x0+1),($this.y1-$this.y0+1),($this.z1-$this.z0+1)
    }

    [long]Volume() {
        return ($this.x1-$this.x0+1)*($this.y1-$this.y0+1)*($this.z1-$this.z0+1)
    }

    [bool]Contains([Cuboid]$c) {
        if ($this.x0 -le $c.x0 -and $this.x1 -ge $c.x1 -and
            $this.y0 -le $c.y0 -and $this.y1 -ge $c.y1 -and
            $this.z0 -le $c.z0 -and $this.z1 -ge $c.z1)
        {
            return $true
        }
        return $false
    }

    [Cuboid]Merge([Cuboid]$c) {
        if ($this.x0 -eq $c.x0 -and $this.x1 -eq $c.x1 -and
            $this.y0 -eq $c.y0 -and $this.y1 -eq $c.y1)
        {
            if ($c.z1 -eq ($this.z0-1)) {
                return [Cuboid]::new($c.x0,$c.x1,$c.y0,$c.y1,$c.z0,$this.z1)
            } elseif ($c.z0 -eq ($this.z1+1)) {
                return [Cuboid]::new($c.x0,$c.x1,$c.y0,$c.y1,$this.z0,$c.z1)
            }
            return $null
        }
        elseif ($this.x0 -eq $c.x0 -and $this.x1 -eq $c.x1 -and
                $this.z0 -eq $c.z0 -and $this.z1 -eq $c.z1)
        {
            if ($c.y1 -eq ($this.y0-1)) {
                return [Cuboid]::new($c.x0,$c.x1,$c.y0,$this.y1,$c.z0,$c.z1)
            } elseif ($c.y0 -eq ($this.y1+1)) {
                return [Cuboid]::new($c.x0,$c.x1,$this.y0,$c.y1,$c.z0,$c.z1)
            }
            return $null
        }
        elseif ($this.y0 -eq $c.y0 -and $this.y1 -eq $c.y1 -and
                $this.z0 -eq $c.z0 -and $this.z1 -eq $c.z1)
        {
            if ($c.x1 -eq ($this.x0-1)) {
                return [Cuboid]::new($c.x0,$this.x1,$c.y0,$c.y1,$c.z0,$c.z1)
            } elseif ($c.x0 -eq ($this.x1+1)) {
                return [Cuboid]::new($this.x0,$c.x1,$c.y0,$c.y1,$c.z0,$c.z1)
            }
            return $null
        }
        return $null
    }

    # Returns an array of cuboids that represent the volume of
    # the specified cuboid after removing the overlapping portion
    # of this cuboid. If this cuboid completely covers the specified
    # cuboid, $null is returned. If the two don't overlap, the
    # specified cubiod is returned as-is.
    [Cuboid[]]Split([Cuboid]$c) {

        # return early if possible
        if ($this.x0 -le $c.x0 -and $this.x1 -ge $c.x1 -and
            $this.y0 -le $c.y0 -and $this.y1 -ge $c.y1 -and
            $this.z0 -le $c.z0 -and $this.z1 -ge $c.z1)
        {
            #Write-Verbose "COVER: $($this.ToString()) <- $($c.ToString())"
            return $null
        }
        if ($c.x1 -lt $this.x0 -or $this.x1 -lt $c.x0 -or
            $c.y1 -lt $this.y0 -or $this.y1 -lt $c.y0 -or
            $c.z1 -lt $this.z0 -or $this.z1 -lt $c.z0)
        {
            #Write-Verbose "NO OL: $($this.ToString()) <- $($c.ToString())"
            return $c
        }

        #Write-Verbose "SPLIT: $($this.ToString()) <- $($c.ToString())"

        $negX = ($c.x0 -lt $this.x0) ? ($this.x0-$c.x0) : 0
        $negY = ($c.y0 -lt $this.y0) ? ($this.y0-$c.y0) : 0
        $negZ = ($c.z0 -lt $this.z0) ? ($this.z0-$c.z0) : 0
        $posX = ($c.x1 -gt $this.x1) ? ($c.x1-$this.x1) : 0
        $posY = ($c.y1 -gt $this.y1) ? ($c.y1-$this.y1) : 0
        $posZ = ($c.z1 -gt $this.z1) ? ($c.z1-$this.z1) : 0
        #Write-Verbose "    overlap dims $negX,$posX,$negY,$posY,$negZ,$posZ"

        $ret = [Collections.Generic.List[Cuboid]]::new(12)

        if ($negX) {
            $nx = [Cuboid]::new(($this.x0-$negX),($this.x0-1),
                                $c.y0,$c.y1,
                                $c.z0,$c.z1)
            $ret.Add($nx)
            #Write-Verbose "    negX = $($nx.ToString()), size $($nx.ToStringDim()), volume $($nx.Volume())"
        }
        if ($posX) {
            $px = [Cuboid]::new(($this.x1+1),($this.x1+$posX),
                                $c.y0,$c.y1,
                                $c.z0,$c.z1)
            $ret.Add($px)
            #Write-Verbose "    posX = $($px.ToString()), size $($px.ToStringDim()), volume $($px.Volume())"
        }
        if ($negY) {
            $ny = [Cuboid]::new([Math]::Max($c.x0,$this.x0),[Math]::Min($c.x1,$this.x1),
                                ($this.y0-$negY),($this.y0-1),
                                $c.z0,$c.z1)
            $ret.Add($ny)
            #Write-Verbose "    negY = $($ny.ToString()), size $($ny.ToStringDim()), volume $($ny.Volume())"
        }
        if ($posY) {
            $py = [Cuboid]::new([Math]::Max($c.x0,$this.x0),[Math]::Min($c.x1,$this.x1),
                                ($this.y1+1),($this.y1+$posY),
                                $c.z0,$c.z1)
            $ret.Add($py)
            #Write-Verbose "    posY = $($py.ToString()), size $($py.ToStringDim()), volume $($py.Volume())"
        }
        if ($negZ) {
            $nz = [Cuboid]::new([Math]::Max($c.x0,$this.x0),[Math]::Min($c.x1,$this.x1),
                                [Math]::Max($c.y0,$this.y0),[Math]::Min($c.y1,$this.y1),
                                ($this.z0-$negZ),($this.z0-1))
            $ret.Add($nz)
            #Write-Verbose "    negZ = $($nz.ToString()), size $($nz.ToStringDim()), volume $($nz.Volume())"
        }
        if ($posZ) {
            $pz = [Cuboid]::new([Math]::Max($c.x0,$this.x0),[Math]::Min($c.x1,$this.x1),
                                [Math]::Max($c.y0,$this.y0),[Math]::Min($c.y1,$this.y1),
                                ($this.z1+1),($this.z1+$posZ))
            $ret.Add($pz)
            #Write-Verbose "    posZ = $($pz.ToString()), size $($pz.ToStringDim()), volume $($pz.Volume())"
        }

        return $ret.ToArray()
    }
}

# init a list of powered on cuboids
$cubes = [Collections.Generic.List[Cuboid]]::new()

foreach ($line in (Get-Clipboard | ?{$_})) {

    if ($line.Length -gt 36 -and -not $p1Count) {
        # save the part 1 total
        $p1Count = $cubes | %{ $_.Volume() } | measure -sum | % sum
    }

    $cubeCount = $cubes.Count

    # parse the input into a cuboid and operation
    $op,[int[]]$v = $line -split '[^-onf0-9]+' | ?{$_}
    [Cuboid[]]$cNew = [Cuboid]::new($v[0],$v[1],$v[2],$v[3],$v[4],$v[5])
    Write-Verbose "$cubeCount cubes - next $op $($cNew[0].ToString())"

    # add the first "on" cube unconditionally
    if ($cubeCount -eq 0) {
        if ($op -eq 'on') { $cubes.Add($cNew[0]) }
        continue
    }

    if ($op -eq 'on') {
        # Split the new cube against the existing cubes
        # so we only have non-overlapping 'on' cubes remaining.
        # But remove existing cubes wholly contained by the
        # new cube.
        for ($i=0; $i -lt $cubeCount; $i++) {
            $cNew = foreach ($c in $cNew) {
                # don't bother checking if the current cube is gone
                if ($null -eq $cubes[$i]) {
                    $c
                    continue
                }
                # mark the current cube for deletion if the new one
                # contains it
                if ($c.Contains($cubes[$i])) {
                    $cubes[$i] = $null
                    $c
                    continue
                }

                # split the new cube against the old one
                $result = $cubes[$i].Split($c)
                if ($null -ne $result) { $result }
            }
        }
        if ($cNew.Count -gt 0) {
            # add them to the 'on' list
            #Write-Verbose "    adding $($cNew.Count) new cubes"
            $cubes.AddRange($cNew)
        }
    }
    else {
        # split the existing cubes against the 'off' cube
        # so only non-overlapping 'on' chunks remain
        for ($i=0; $i -lt $cubeCount; $i++) {
            $cLeft = $cNew.Split($cubes[$i])

            if ($cLeft.Count -eq 0) {
                # no result means the 'off' cube entirely turned
                # off this cube, so we need to remove it
                #Write-Verbose "    setting cube $i to null"
                $cubes[$i] = $null
            }
            else {
                # replace the current cube with the first result
                if (-not $cLeft[0].Contains($cubes[$i])) {
                    #Write-Verbose "    replacing cube $i"
                    $cubes[$i] = $cLeft[0]
                }

                if ($cLeft.Count -gt 1) {
                    # add the rest to the end of the list
                    #Write-Verbose "    adding $($cLeft.Count-1) split cubes"
                    $cubes.AddRange([Cuboid[]]$cLeft[1..($cLeft.Count-1)])
                }
            }
        }
    }

    # remove the cube indexes set to null
    for ($i=($cubeCount-1); $i -ge 0; $i--) {
        if ($null -eq $cubes[$i]) {
            #Write-Verbose "    removing cube $i"
            $cubes.RemoveAt($i)
        }
    }

    # # Find and merge adjacent cubes of the same size
    # for ($i=0; $i -lt $cubes.Count; $i++) {
    #     for ($j=$i+1; $j -lt $cubes.Count; $j++) {
    #         if ($null -eq $cubes[$i] -or $null -eq $cubes[$j]) { continue }
    #         $merged = $cubes[$i].Merge($cubes[$j])
    #         if ($merged) {
    #             $merge++
    #             #Write-Warning "    MERGE $($cubes[$i]) <-> $($cubes[$j]) = $($merged)"
    #             $cubes[$i] = $merged
    #             $cubes[$j] = $null
    #         }
    #     }
    # }

    # # remove the cube indexes set to null
    # $cubeCount = $cubes.Count
    # for ($i=($cubeCount-1); $i -ge 0; $i--) {
    #     if ($null -eq $cubes[$i]) {
    #         #Write-Verbose "    removing cube $i"
    #         $cubes.RemoveAt($i)
    #     }
    # }
}
Write-Verbose "total cubes: $($cubes.Count)"

Write-Host "Part 1: $p1Count"

[long[]]$p2Sizes = $cubes | %{ [long]$_.Volume() }
[long]$p2Count = 0
$p2Sizes | %{ $p2Count += $_ }
Write-Host "Part 2: $p2Count"
