
[CmdletBinding()]
param(
    $InputFile = '.\d1.txt'
)

# https://adventofcode.com/2022/day/1

$data = (Get-Content $InputFile -Raw).Trim()
Set-Clipboard $data

    # split the lists per elf
    $lists = (Get-Clipboard -Raw) -split "`n`n"

    # sum each list and sort in descending order
    $sums = $lists | ForEach-Object {
        $_ -split "`n" | Measure-Object -Sum | Select-Object -Expand Sum
    } | Sort-Object -Descending

    # Part 1
    $sums[0]

    # Part 2
    $sums[0..2]| Measure-Object -Sum | Select-Object -Expand Sum

    # Golfed both
    $p=$InputFile
    ($s=gc $p -del "`n`n"|%{$_.Trim()-replace"`n",'+'|iex}|sort)[-1];$s[-3..-1]-join'+'|iex
