[CmdletBinding()]
param(
    [string]$InputFile = '.\d21.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# parse the data into a nice set of custom objects
$data = Get-Content $InputFile | ForEach-Object {
    $ing,$alg = $_ -replace '[(),]' -split ' contains '
    [pscustomobject]@{
        ing = $ing -split ' '
        alg = $alg -split ' '
    }
}

# Build a hashtable that contains each allergen as the key
# with each ingredient that could be associated with it.
# The first time an allergen is encountered, every ingredient
# will be added. But every instance after should shrink the
# list because we only want ingredients that appear in every
# reference.
$algMap = @{}
$data | ForEach-Object {
    $ing = $_.ing
    foreach ($alg in $_.alg) {
        $oldIng = $algMap[$alg]
        $algMap[$alg] = ($oldIng) ? @($ing | ?{ $_ -in $oldIng }) : @($ing)
    }
}

# assuming "nice" data, we should now have at least one allergen
# that is only associated with a single ingredient and if we remove
# that ingredient from the rest of the allergen lists, we should continue
# to find a new single ingredient allergen until all allergens are only
# associated with one.
$finalized = @()
0..($algMap.Count-2) | ForEach-Object {
    # find the allergen with only one ingredient
    $alg = $algMap.GetEnumerator() | Where-Object {
        $_.Value.Count -eq 1 -and $_.Name -notin $finalized
    }
    # # add it to the finalized list
    $finalized += $alg.Name
    # remove the ingredient from the rest of the allergens
    foreach ($key in $($algMap.Keys | ?{ $_ -notin $finalized })) {
        $algMap.$key = @($algMap.$key | ?{ $_ -ne $alg.Value[0] })
    }
}


# Part 1
if (-not $NoPart1) {

    $allIng = $data | %{ $_.ing | %{ $_ } }
    $badIng = $algMap.Values | %{ $_[0] }
    ($allIng | Where-Object { $_ -notin $badIng }).Count

}


# Part 2
if (-not $NoPart2) {

    $badIng = $algMap.Keys | Sort-Object | ForEach-Object {
        $algMap[$_][0]
    }
    $badIng -join ','

}
