#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d5.txt',
    [switch]$NoPart2
)

# https://adventofcode.com/2019/day/5

function RunProg {
    [CmdletBinding()]
    param(
        [string]$InputFile,
        [int]$InputInstruction
    )

    [int[]]$mem = (Get-Content $InputFile -Raw).Trim().Split(',')

    $pos = 0

    while ($true) {
        $op = $mem[$pos] % 100

        [string]$modes = "{0:000}" -f [Math]::Floor($mem[$pos] / 100)  #pads leading zeroes to three units

        switch ($op) {
            1 { #add
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $mem[$mem[$pos+3]] = $p1 + $p2
                $pos += 4
                break
            }
            2 { #multiply
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $mem[$mem[$pos+3]] = $p1 * $p2
                $pos += 4
                break
            }
            3 { #take input and write to disk
                $mem[$mem[$pos+1]] = $InputInstruction
                $pos += 2
                break
            }
            4 { #output
                ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $pos += 2
                break
            }
            5 { #jump-if-true
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $pos = ($p1 -ne 0) ? $p2 : ($pos+3)
                break
            }
            6 { #jump-if-false
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $pos = ($p1 -eq 0) ? $p2 : ($pos+3)
                break
            }
            7 { #less than
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $mem[$mem[$pos+3]] = ($p1 -lt $p2) ? 1 : 0
                $pos += 4
                break
            }
            8 { #equality
                $p1 = ($modes[-1] -eq '0') ? $mem[$mem[$pos+1]] : $mem[$pos+1]
                $p2 = ($modes[-2] -eq '0') ? $mem[$mem[$pos+2]] : $mem[$pos+2]
                $mem[$mem[$pos+3]] = ($p1 -eq $p2) ? 1 : 0
                $pos += 4
                break
            }
            99 { return "HALT" }
            Default { throw "$op is not a real OpCode" }
        }
    }

}

RunProg $InputFile 1


RunProg $InputFile 5
