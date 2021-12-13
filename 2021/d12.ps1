#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d12.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/12

$data = Get-Content $InputFile
Set-Clipboard $data

# create a Dictionary that maps forward/reverse connections
$conn = [Collections.Generic.Dictionary[string,[Collections.Generic.List[string]]]]::new()

# regex for upper-case chars (make sure to use -cmatch)
$reLower = [regex]'[a-z]+'

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

$script:pathCount = 0

function Get-PathCount {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Room = 'start',
        [Parameter(Position=1)]
        [string[]]$Seen = @(),
        [switch]$Part2
    )

    if ($Room -eq 'end') {
        $script:pathCount += 1
        return
    }

    if ($Room -in $Seen) {
        if ($Room -eq 'start') {
            return
        }
        if ($Room -cmatch $reLower) {
            if (-not $Part2) {
                return
            }
            else { $Part2 = $false }
        }
    }

    # add this room to the Seen list
    $Seen += $Room

    foreach ($nbr in $conn[$Room]) {
        Get-PathCount $nbr $Seen -Part2:$Part2
    }
}

Get-PathCount -Part2:$Part2
Write-Host $script:pathCount
