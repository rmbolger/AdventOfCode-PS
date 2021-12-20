#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d20.txt'
)

# https://adventofcode.com/2021/day/20

$data = Get-Content $InputFile -Raw
Set-Clipboard $data

    $algoRaw,$imgRaw = (Get-Clipboard -Raw).Trim() -split "`n`n"

    # read the algorithm into an array of 0/1
    [int[]]$algo = foreach ($c in $algoRaw.ToCharArray()) { ($c -eq '#') ? 1 : 0 }

    # Read the input image into a dictionary that maps each coord to its expanded
    # set of coords. Also, put each lit pixel's coord into a HashSet
    $imgLines = $imgRaw -split "`n"
    $bitDeltas = '[[-1,-1],[0,-1],[1,-1],[-1,0],[0,0],[1,0],[-1,1],[0,1],[1,1]]' | ConvertFrom-Json
    $coords = [Collections.Generic.Dictionary[string,string[]]]::new($imgLines.Count*$imgLines[0].Length*2)
    $img = [Collections.Generic.HashSet[string]]::new()
    $minX=$maxX=$minY=$maxY=0
    for ($y=-2; $y -lt $imgLines.Count+2; $y++) {
        for ($x=-2; $x -lt $imgLines[0].Length+2; $x++) {

            # add bit coords to dictionary
            $bits = foreach ($d in $bitDeltas) {
                '{0},{1}' -f ($x+$d[0]),($y+$d[1])
            }
            $coords[$bits[4]] = $bits

            # add lit pixel to HashSet
            if ($x -ge 0 -and $x -lt $imgLines[0].Length -and
                $y -ge 0 -and $y -lt $imgLines.Count
            ) {
                if ($imgLines[$y][$x] -eq '#') { $null = $img.Add($bits[4]) }
                if     ($x -lt $minX) { $minX = $x }
                elseif ($x -gt $maxX) { $maxX = $x }
                if     ($y -lt $minY) { $minY = $y }
                elseif ($y -gt $maxY) { $maxY = $y }
            }
        }
    }

    $borderFlash = $algo[0] -and -not $algo[511]

    for ($i=1; $i -le 50; $i++) {

        # initialize the updated image
        $imgNew = [Collections.Generic.HashSet[string]]::new($img.Count*2)
        $minXNew=$maxXNew=$minYNew=$maxYNew=0

        # add the 'infinite' lit border on odd iterations
        # which is a 3-pixel deep lit border starting
        # 3 pixels away from the previous iteration's lit bounds
        if ($borderFlash -and ($i % 2) -eq 1) {
            foreach ($x in ($minX-5)..($maxX+5)) {
                $null = $imgNew.Add(('{0},{1}' -f $x,($minY-3)))
                $null = $imgNew.Add(('{0},{1}' -f $x,($minY-4)))
                $null = $imgNew.Add(('{0},{1}' -f $x,($minY-5)))
                $null = $imgNew.Add(('{0},{1}' -f $x,($maxY+3)))
                $null = $imgNew.Add(('{0},{1}' -f $x,($maxY+4)))
                $null = $imgNew.Add(('{0},{1}' -f $x,($maxY+5)))
            }
            foreach ($y in ($minY-2)..($maxY+2)) {
                $null = $imgNew.Add(('{0},{1}' -f ($minX-3),$y))
                $null = $imgNew.Add(('{0},{1}' -f ($minX-4),$y))
                $null = $imgNew.Add(('{0},{1}' -f ($minX-5),$y))
                $null = $imgNew.Add(('{0},{1}' -f ($maxX+3),$y))
                $null = $imgNew.Add(('{0},{1}' -f ($maxX+4),$y))
                $null = $imgNew.Add(('{0},{1}' -f ($maxX+5),$y))
            }
        }

        # process the grid of pixels that comprise the old image
        # plus a 2 pixel border of unlit pixels
        for ($y=($minY-2); $y -le ($maxY+2); $y++) {
            for ($x=($minX-2); $x -le ($maxX+2); $x++) {

                $key = '{0},{1}' -f $x,$y

                # get the bit coords for this point
                if (-not ($bitCoords = $coords[$key])) {
                    # add missing coords to dictionary if necessary
                    $bitCoords = foreach ($d in $bitDeltas) {
                        '{0},{1}' -f ($x+$d[0]),($y+$d[1])
                    }
                    $coords[$key] = $bitCoords
                }

                # build the algo index for this coord
                $val = 0
                foreach ($c in $bitCoords) { $val = ($val -shl 1) + [int]$img.Contains($c) }

                # add the pixel if lit and adjust bounds
                if ($algo[$val]) {
                    $null = $imgNew.Add($key)

                    if     ($x -lt $minXNew) { $minXNew = $x }
                    elseif ($x -gt $maxXNew) { $maxXNew = $x }
                    if     ($y -lt $minYNew) { $minYNew = $y }
                    elseif ($y -gt $maxYNew) { $maxYNew = $y }
                }
            }
        }

        # update the image and bounds for the next iteration
        $img = $imgNew
        $minX = $minXNew
        $maxX = $maxXNew
        $minY = $minYNew
        $maxY = $maxYNew

        if ($i -eq 2) {
            Write-Host "Part 1: $($img.Count)"
        }
    }
    Write-Host "Part 2: $($img.Count)"
