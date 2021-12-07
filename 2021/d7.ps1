#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d7.txt'
)

# https://adventofcode.com/2021/day/7

$data = Get-Content $InputFile
Set-Clipboard $data

$pos = [int[]]((gcb) -split ',') | Sort-Object

$median = if ($pos.Count % 2) {
    $pos[[Math]::Floor($pos.Count/2)]
} else {
    $pos[$pos.Count/2],$pos[$pos.Count/2-1] | measure -average | % average
}
Write-Verbose "median = $median"

$pos | %{ [Math]::Abs($_ - $median) } | measure -sum | % sum


$pos[0]..$pos[-1] | %{
    $p = $_
    #Write-Verbose "`$p = $p"
    $fuel = $pos | %{
        $delta = [Math]::Abs($_ - $p)
        $f = (1..$delta | %{"$_"}) -join '+' | iex
        $f
        #Write-Verbose "    $_ - $p = $f"
    } | measure -sum | % sum
    [pscustomobject]@{
        pos = $p
        fuel = $fuel
    }
} | sort fuel | select -first 1
