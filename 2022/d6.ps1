#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d6.txt'
)

# https://adventofcode.com/2022/day/6

    $buf = (Get-Content $InputFile -Raw).Trim().ToCharArray()

    # Part 1
    for ($i=3; $i -lt $buf.Count; $i++) {
        $seq = $buf[($i-3)..$i]
        if (($seq | Group-Object).Count -eq 4) {
            $i+1; break
        }
    }

    # Part 2
    for ($i=13; $i -lt $buf.Count; $i++) {
        $seq = $buf[($i-13)..$i]
        if (($seq | Group-Object).Count -eq 14) {
            $i+1; break
        }
    }
