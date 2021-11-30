#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d6.txt'
)

# https://adventofcode.com/2019/day/6

# build a hash table of parents and children
$orbits = @{}
Get-Content $InputFile | ForEach-Object {
    $parent,$child = $_ -split '\)'
    $orbits[$parent] = $orbits[$parent] ? ($orbits[$parent] + ",$child") : $child
}

# Part 1

function Get-OrbitCount {
    [CmdletBinding()]
    param(
        [pscustomobject]$curOrbit,
        [int]$curDepth
    )

    $count = 0

    if ($null -ne $orbits[$curOrbit.Name])
    {
        foreach($child in ($orbits[$curOrbit.Name] -split ','))
        {
            $childOrbit = [pscustomobject]@{
                Name = $child
                Parent = $curOrbit
                Children = @()
            }

            if($child -eq "SAN") { $script:SANTA = $childOrbit }
            if($child -eq "YOU") { $script:YOU = $childOrbit }

            $curOrbit.Children += $childOrbit
            $count += (Get-OrbitCount -curOrbit $childOrbit -curDepth ($curDepth + 1))
        }
    }
    return $count + $curDepth
}

function Get-PathToCenter
{
    [CmdletBinding()]
    param(
        [pscustomobject]$orbit
    )

    $comPath = @($orbit.Name)
    $parent = $orbit.Parent
    while ($null -ne $parent)
    {
        $comPath += $parent.Name
        $parent = $parent.Parent
    }
    return $comPath
}

function Get-Distance {
    [CmdletBinding()]
    param(
        [pscustomobject]$orbit1,
        [pscustomobject]$orbit2
    )

    # we can find the shortest distance between two orbits by finding the path
    # to COM for each of them, removing the shared segments, and counting what's
    # left.

    $comPath1 = Get-PathToCenter $orbit1
    $comPath2 = Get-PathToCenter $orbit2

    [array]::Reverse($comPath1)
    [array]::Reverse($comPath2)

    $max = [Math]::Max($comPath1.Length,$comPath2.Length)

    for($i = 0; $i -lt $max; $i++)
    {
        if($comPath1[$i] -ne $comPath2[$i])
        {
            # Subtract 2 to account for the fact that you and santa are both not oribits to transfer to or from
            return ($comPath1.Length + $comPath2.Length - (2 * $i) - 2)
        }
    }
}

$comOrbit = [pscustomobject]@{
    Name = 'COM'
    Parent = $null
    Children = @()
}
$script:SANTA = [pscustomobject]@{
    Name = 'SAN'
    Parent = $null
    Children = @()
}
$script:YOU = [pscustomobject]@{
    Name = 'YOU'
    Parent = $null
    Children = @()
}

Get-OrbitCount $comOrbit 0

Get-Distance $SANTA $YOU
