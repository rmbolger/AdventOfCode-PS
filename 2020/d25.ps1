[CmdletBinding()]
param(
    [string]$InputFile = '.\d25.txt'
)

$pkCard,$pkDoor = [int[]](Get-Content $InputFile)

$lsCard = 0
$val = [long]1
$subjNum = 7

while ($val -ne $pkCard) {
    $val = ($val * $subjNum) % 20201227
    $lsCard++
}
Write-Verbose "Card loop size $lsCard"

$val = [long]1
for ($loop=0; $loop -lt $lsCard; $loop++) {
    $val = ($val * $pkDoor) % 20201227
    #Write-Verbose $val
}

# Why doesn't this alternate method work?
# Numbers too big to do all at once rather than sequentially modded?
# [Math]::Pow($pkDoor,$lsCard) % 20201227

Write-Host "Encryption Key: $val"
