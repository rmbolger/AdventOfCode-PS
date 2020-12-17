[CmdletBinding()]
param(
    [string]$InputFile = '.\d1.txt'
)

$d1 = Get-Content $InputFile

# Part 1
$found = $false
foreach ($i in $d1) {
    foreach ($j in $d1) {
        if ( ([int]$i+$j) -eq 2020) {
            Write-Verbose "$i + $j = 2020. $i * $j = $([int]$i*$j)"
            ([int]$i * $j)
            $found = $true
            break
        }
    }
    if ($found) { break }
}

# Part 2
$found = $false
foreach ($i in $d1) {
    foreach ($j in $d1) {
        foreach ($k in $d1) {
            if (([int]$i+$j+$k) -eq 2020) {
                Write-Verbose "$i + $j + $k = 2020. $i * $j * $k = $([int]$i*$j*$k)"
                ([int]$i * $j * $k)
                $found = $true
                break
            }
        }
        if ($found) { break }
    }
    if ($found) { break }
}
