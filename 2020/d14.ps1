[CmdletBinding()]
param(
    [string]$InputFile = '.\d14.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$lines = Get-Content $InputFile

function Convert-WithMask {
    param(
        [long]$Value,
        [string]$Mask
    )

    $maskOr  = [Convert]::ToInt64($Mask.Replace('X','0'),2)
    $maskAnd = [Convert]::ToInt64($Mask.Replace('X','1'),2)

    $Value -bor $maskOr -band $maskAnd
}

# Part 1
if (-not $NoPart1) {

    $addrs = @{}
    switch -Regex ($lines) {
        'mask = ([X10]+)' {
            $mask = $matches[1]
        }
        'mem\[(\d+)\] = (\d+)' {
            $addr = $matches[1]
            $val = [long]$matches[2]
            $addrs[$addr] = Convert-WithMask $val $mask
            #Write-Verbose "mem[$addr] = $($addrs[$addr])"
        }
    }
    ($addrs.Values | measure -sum).Sum

}


# Part 2
if (-not $NoPart2) {

    function Expand-MaskList {
        [CmdletBinding()]
        param([string]$Mask)

        # Mask 000000000000000000000000000000X1001X should expand to
        #      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01XX10
        #      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX11XX10
        #      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01XX11
        #      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX11XX11

        $results = @('')
        foreach ($c in $Mask.ToCharArray()) {
            if ($c -eq '0') {
                # add X to all results
                0..($results.Count-1) | %{ $results[$_] += 'X' }
                #Write-Verbose "0 -> X:`n$($results -join "`n")"
            }
            elseif ($c -eq '1') {
                # add 1 to all results
                0..($results.Count-1) | %{ $results[$_] += '1' }
                #Write-Verbose "1 -> 1:`n$($results -join "`n")"
            }
            else {
                # double the results and
                # append 1 to half and 0 to the other half
                $results += $results
                0..($results.Count/2 - 1) | %{ $results[$_] += '1' }
                ($results.Count/2)..($results.Count-1) | %{ $results[$_] += '0' }
                #Write-Verbose "X -> split 1/0:`n$($results -join "`n")"
            }
        }
        $results
    }

    $addrs = @{}
    switch -Regex ($lines) {
        'mask = ([X10]+)' {
            # expand the mask into a list of part1 masks
            $masks = Expand-MaskList $matches[1]
        }
        'mem\[(\d+)\] = (\d+)' {
            $addr = [long]$matches[1]
            $val = [long]$matches[2]

            # write the value to each address modified by the
            # current mask list
            $masks | %{
                #Write-Verbose "mem[$addr] -> mem[$((Convert-WithMask $addr $_))] = $val"
                $addrs[(Convert-WithMask $addr $_)] = $val
            }
        }
    }
    ($addrs.Values | measure -sum).Sum

}
