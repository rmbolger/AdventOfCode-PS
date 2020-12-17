[CmdletBinding()]
param(
    [string]$InputFile = '.\d2.txt'
)

$d2 = Get-Content $InputFile

$policies = $d2 | ForEach-Object {
    if ($_ -match '(?<min>\d+)-(?<max>\d+) (?<letter>[a-z]): (?<pass>.+)') {
        [pscustomobject]@{
            min    = [int]$matches.min
            max    = [int]$matches.max
            letter = $matches.letter
            pass   = $matches.pass
        }
    }
}

# Part 1
$goodPolicies = foreach ($p in $policies) {
    $count = ($p.pass.Length - $p.pass.Replace($p.letter,'').Length)
    if ($count -ge $p.min -and $count -le $p.max) {
        $p
    }
}
$goodPolicies.Count


# Part 2
$goodPolicies = foreach ($p in ($policies)) {
    if ($p.pass[$p.min-1] -eq $p.letter -xor $p.pass[$p.max-1] -eq $p.letter) {
        $p
    }
}
$goodPolicies.Count
