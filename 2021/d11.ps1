#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d11.txt',
    [switch]$ShowViz
)

# https://adventofcode.com/2021/day/11

$data = Get-Content $InputFile
Set-Clipboard $data

# instead of organizing the grid into a 2D array, we're going to encode
# the x,y coords into a single 8-bit integer by -shl'ing the y 4 bits
# to the left and -bor'ing the x.

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
            $xy = $y -shl 4 -bor $x
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

                $dxy = $dy -shl 4 -bor $dx
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

    $colorVal = @{
        0 = 0x00305f
        1 = 0x104478
        2 = 0x2c578d
        3 = 0x3d659d
        4 = 0x5379b2
        5 = 0x698ec9
        6 = 0x7ea3df
        7 = 0x94b8f6
        8 = 0xabceff
        9 = 0xffffff
    }
    #10..20 | %{ $colorVal.$_ = 0xc1e5ff }  # post-flash slightly less
    10..20 | %{ $colorVal.$_ = 0x00305f }   # post-flash immediately dark

    function Out-OctoGrid {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory,ValueFromPipeline)]
            [Collections.Generic.Dictionary[int,int]]$grid,
            [int]$DelayMs=50
        )

        Process {
            if (-not $ShowViz) { return }
            # Ʊ - octo char
            Clear-Host
            ''
            for ($y=0; $y -lt $lines.Count; $y++) {
                $chars = for ($x=0; $x -lt $lines[0].Length; $x++) {
                    $xy = $y -shl 4 -bor $x
                    " $($PSStyle.Foreground.FromRgb($colorVal[$grid.$xy]))Ʊ"
                }
                $chars -join ''
            }
            $PSStyle.Reset
            Start-Sleep -Milliseconds $DelayMs
        }
    }

    $flashed = [Collections.Generic.List[int]]::new(200)
    Out-OctoGrid $octEnergy

    while ($true) {
        $i += 1

        # increment all octos
        #Write-Verbose "$i - increment"
        foreach ($key in $octEnergy.Keys) {
            $octEnergy.$key += 1
        }
        $octEnergy | Out-OctoGrid

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
            $octEnergy | Out-OctoGrid
        }

        # count and zero out the flashed
        if ($i -le 100) { $totalFlashed += $flashed.Count }
        foreach ($xy in $flashed) {
            $octEnergy[$xy] = 0
        }
        $octEnergy | Out-OctoGrid

        # check for Part 2 completion
        if ($flashed.Count -eq 100) {
            break
        }
    }
    Write-Host "$totalFlashed total flashed after 100 steps"
    Write-Host "All flashed on step $i"
