#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d11.txt'
)

# https://adventofcode.com/2021/day/11

$data = Get-Content $InputFile
Set-Clipboard $data

# instead of organizing the grid into a 2D array, we're going to encode
# the x,y coords into a single 8-bit integer by -shl'ing the x 4 bits
# to the left and -bor'ing the y.

    $octEnergy = [Collections.Generic.Dictionary[int,int]]::new(200)
    $octNbrs = [Collections.Generic.Dictionary[int,int[]]]::new(200)

    $deltas = @(
        ,@(-1, 0)    # w
        ,@(-1,-1)    # nw
        ,@( 0,-1)    # n
        ,@( 1,-1)    # ne
        ,@( 1, 0)    # e
        ,@( 1, 1)    # se
        ,@( 0, 1)    # s
        ,@(-1, 1)    # sw
    )

    # initialize the "grid" and the neighbor "coords"
    $lines = Get-Clipboard
    for ($y=0; $y -lt $lines.Count; $y++) {
        for ($x=0; $x -lt $lines[0].Length; $x++) {
            $xy = $x -shl 4 -bor $y
            $val = [int]$lines[$y][$x]-48
            if (-not ($octEnergy.ContainsKey($xy))) {
                $octEnergy.$xy = $val
                #Write-Verbose "$x,$y ($xy) = $val"
            }

            # grab neighbor coords
            $nbrs = foreach ($d in $deltas) {
                # bounds check
                $dx = $x+$d[0]
                $dy = $y+$d[1]
                if ($dx -lt 0 -or $dx -gt 9) { continue }
                if ($dy -lt 0 -or $dy -gt 9) { continue }

                $dxy = $dx -shl 4 -bor $dy
                # add the energy now if it's not already there
                if (-not ($octEnergy.ContainsKey($dxy))) {
                    $octEnergy.$dxy = [int]$lines[$dy][$dx]-48
                    #Write-Verbose "$dx,$dy ($dxy) = $($octEnergy.$dxy)"
                }
                $dxy
            }
            $octNbrs.$xy = [int[]]$nbrs
            #Write-Verbose "    neighbors = $($nbrs -join ',')"
        }
    }

function Out-OctoGrid {
    [CmdletBinding()]
    param(
        [Collections.Generic.Dictionary[int,int]]$grid
    )
    for ($y=0; $y -lt $lines.Count; $y++) {
        $chars = for ($x=0; $x -lt $lines[0].Length; $x++) {
            $xy = $x -shl 4 -bor $y

            $grid.$xy.ToString().PadLeft(3)
        }
        $chars -join ''
    }
    ''
}

    $flashed = [Collections.Generic.List[int]]::new(200)

    while ($true) {
        $i += 1

        # increment all octos
        #Write-Verbose "$i - increment"
        foreach ($key in $octEnergy.Keys) {
            $octEnergy.$key += 1
        }

        $flashed.Clear()
        while ($flashing = ($octEnergy.GetEnumerator() | ?{ $_.Value -gt 9 -and $_.Key -notin $flashed})) {
            #Write-Verbose "$i - flashing $($flashing.Key -join ',')"
            foreach ($xy in $flashing.Key) {
                # add to the already flashed list
                $flashed.Add($xy)
                # upgrade the neighbors
                foreach ($nbr in $octNbrs[$xy]) {
                    $octEnergy.$nbr += 1
                }
            }
        }

        # count and zero out the flashed
        $totalFlashed += $flashed.Count
        foreach ($xy in $flashed) {
            $octEnergy[$xy] = 0
        }

        # Output Part 1 when we get there
        if ($i -eq 100) {
            Write-Host "$totalFlashed total flashed after 100 steps"
        }

        # check for Part 2 completion
        if ($flashed.Count -eq 100) {
            Write-Host "All flashed on step $i"
            break
        }

        #Out-OctoGrid $octEnergy
    }
