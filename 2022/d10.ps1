#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d10.txt'
)

# https://adventofcode.com/2022/day/10

class EPhone {
    [int]$cycle = 1
    [int]$x = 1
    [int[]]$sprite = 0,1,2
    [char[][]]$crt = @(
        '                                        '.ToCharArray(),
        '                                        '.ToCharArray(),
        '                                        '.ToCharArray(),
        '                                        '.ToCharArray(),
        '                                        '.ToCharArray(),
        '                                        '.ToCharArray()
    )
    [int]$crtLine = 0
    [int]$signalSum = 0

    [void]DoCycle([int]$Add) {

        # draw the next pixel
        if (($this.cycle-1)%40 -in $this.sprite) {
            $this.crt[$this.crtLine][($this.cycle-1)%40] = '#'
        }
        #Write-Verbose "c$($this.cycle) x$($this.x) $Add - $($this.crt[$this.crtLine] -join '') - row $($this.crtLine)"

        # If we have a value, add it and move the sprite
        if ($Add -ne 0) {
            $this.x += $Add
            $this.sprite = ($this.x-1),$this.x,($this.x+1)
        }

        # move to next CRT line if necessary
        if ($this.cycle%40 -eq 0) {
            $this.crtLine++
            #Write-Verbose "c$($this.cycle) crt$($this.crtLine)"
        }

        $this.cycle++

        # emit Part 1 signal strength
        if (($this.cycle-20)%40 -eq 0) {
            $this.signalSum += $this.cycle * $this.x
            #Write-Verbose "c$($this.cycle) * x$($this.x) = $($this.cycle*$this.x)"
        }

    }
}

$phone = [EPhone]::new()

switch -Regex (Get-Content $InputFile) {
    'noop' {
        $phone.DoCycle(0)
    }
    'addx (\S+)' {
        #$addx = $matches[1]
        $phone.DoCycle(0)
        $phone.DoCycle($matches[1])
    }
}
$phone.signalSum

# Part 2 Output
$phone.crt | ForEach-Object { $_ -join '' }