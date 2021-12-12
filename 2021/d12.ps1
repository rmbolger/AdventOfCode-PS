#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d12.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/12

$data = Get-Content $InputFile
Set-Clipboard $data

# maintain the set of paths as a List of Stacks
$paths = [Collections.Generic.List[[Collections.Generic.Stack[string]]]]::new()

# create a Dictionary that maps forward/reverse connections
$conn = [Collections.Generic.Dictionary[string,[Collections.Generic.List[string]]]]::new()

# regex for upper-case chars (make sure to use -cmatch)
$reUpper = [regex]'[A-Z]+'

function CloneStack {
    $a = $args[0].ToArray()
    [array]::Reverse($a)
    ,[Collections.Generic.Stack[string]]::new($a)
}

# load the input into the connections Dict
Get-ClipBoard | %{
    $a,$b = $_ -split '-'
    if (-not $conn.ContainsKey($a)) {
        $conn[$a] = [Collections.Generic.List[string]]::new()
    }
    if (-not $conn.ContainsKey($b)) {
        $conn[$b] = [Collections.Generic.List[string]]::new()
    }
    if ($b -ne 'start') { $conn[$a].Add($b) }
    if ($a -ne 'start') { $conn[$b].Add($a) }
}

$conn['start'] | %{
    $p = [Collections.Generic.Stack[string]]::new()
    $p.Push('start')
    $p.Push($_)
    $paths.Add($p)
    Write-Verbose "    $($p -join '-') (initial)"
}

while ($notDone = $paths | Where-Object { $_.Peek() -ne 'end' }) {

    foreach ($p in $notDone) {
        $last = $p.Peek()

        # what adjacent rooms we're allowed to go through next depends on
        # which part we're on.
        if (-not $Part2) {
            # any upper-case rooms or lower-case rooms we haven't yet visited
            $adj = @($conn[$last] | Where-Object {
                $_ -cmatch $reUpper -or -not $p.Contains($_)
            })
        } else {
            # any upper-case rooms
            # one lower-case room can appear twice
            # the rest can only appear once

            # check if we're still allowed to duplicate a lower-case room
            $noDupeLower = ($null -ne ($p | Where-Object {
                $_ -cnotmatch $reUpper
            } | Group-Object | Where-Object {
                $_.Count -ge 2
            }))

            $adj = @($conn[$last] | Where-Object {
                $room = $_
                ($room -cmatch $reUpper -or -not $noDupeLower -or
                    ($noDupeLower -and -not $p.Contains($_))
                )
            })
        }

        #Write-Verbose "last: $last adj: $($adj -join ',') from $($conn[$last] -join ',')"
        if ($adj.Count -eq 0) {
            # path can't continue, so fake end it
            $p.Push('END')
            #Write-Verbose "    $($p -join '-') (FAKE)"
        }
        else {
            if ($adj.Count -gt 1) {
                # clone the path for each additional room beyond the first
                for ($i=1; $i -lt $adj.Count; $i++) {
                    $pNew = CloneStack $p
                    $pNew.Push($adj[$i])
                    $paths.Add($pNew)
                    #Write-Verbose "    $($pNew -join '-') (clone)"
                }
            }
            # add the first room to the original path
            $p.Push($adj[0])
            #Write-Verbose "    $($p -join '-')"
        }
    }
}

$count = ($paths | ?{ $_.Peek() -cne 'END' } | %{
    $_ -join '-'
}).Count

Write-Host $count
