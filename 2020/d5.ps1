[CmdletBinding()]
param(
    [string]$InputFile = '.\d5.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$d5 = Get-Content $InputFile

# the seat code is ultimately just a binary number representation
# where B/R = 1 and F/L = 0
# So BFFFBFBLRL = 1000101010 = 554
$seats = $d5 | ForEach-Object {
    $binaryString = $_ -replace'B|R', 1 -replace 'F|L', 0
    $id = [Convert]::ToInt32($binaryString, 2)
    Write-Verbose "$_ = $binaryString = $id"
    $id
} | Sort-Object

# Part 1
if (-not $NoPart1) {
    # seat IDs are sorted so highest = last
    $seats[-1]
}

# Part 2
if (-not $NoPart2) {

    # the seats are in order of ID and ours should be the only one missing, so
    # find the one that's missing
    $seats[0]..$seats[-1] | Where-Object { $_ -notin $seats }

}
