#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d18.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/18

$data = Get-Content $InputFile
Set-Clipboard $data

    function Add-Left {
        #[CmdletBinding()]
        param(
            $SN,
            [int64]$n
        )
        $script:Add += 1
        #Write-Verbose "Add-Left: $($SN | ConvertTo-Json -Comp -Dep 10) $($n | ConvertTo-Json -Comp -Dep 10)"
        if ($null -eq $n) {
            return $SN
        }
        if ($SN.Count -eq 1) {
            return ($SN + $n)
        }

        $newLeft = Add-Left $SN[0] $n
        return $newLeft,$SN[1]
    }

    function Add-Right {
        #[CmdletBinding()]
        param(
            $SN,
            [int64]$n
        )
        $script:Add += 1
        #Write-Verbose "Add-Right: $($SN | ConvertTo-Json -Comp -Dep 10) $($n | ConvertTo-Json -Comp -Dep 10)"
        if ($null -eq $n) {
            return $SN
        }
        if ($SN.Count -eq 1) {
            return ($SN + $n)
        }

        $newRight = Add-Right $SN[1] $n
        return $SN[0],$newRight
    }

    function Invoke-Explode {
        #[CmdletBinding()]
        param(
            $SN,
            [int]$DepthRemaining=4
        )
        $script:Explode += 1

        #Write-Verbose "check explode: $($SN | ConvertTo-Json -Comp -Dep 10)"
        # The output of this function is an array of
        # four elements:
        # - true/false : whether there was a change
        # - the left value, if exploded
        # - 0 (if exploded) or the updated $SN for this position
        # - the right value if exploded

        # return literals as-is
        if ($SN.Count -eq 1) {
            #Write-Verbose "no change, literal $SN"
            return $false,$null,$SN,$null
        }

        # explode if we've reached critical depth
        if ($DepthRemaining -eq 0) {
            #Write-Verbose "explode $($SN[0] | ConvertTo-Json -Compress),$($SN[1] | ConvertTo-Json -Compress)"
            return $true,$SN[0],0,$SN[1]
        }

        $a,$b = $SN

        # recurse left
        $change,$left,$a,$right = Invoke-Explode $a ($DepthRemaining-1)
        if ($change) {
            return $true,$left,@($a,(Add-Left $b $right)),$null
        }

        # recurse right
        $change,$left,$b,$right = Invoke-Explode $b ($DepthRemaining-1)
        if ($change) {
            return $true,$null,@((Add-Right $a $left),$b),$right
        }

        return $false,$null,$SN,$null
    }

    function Invoke-Split {
        #[CmdletBinding()]
        param($SN)
        $script:Split += 1

        #Write-Verbose "check split: $($SN | ConvertTo-Json -Comp -Dep 10)"

        if ($SN.Count -eq 1) {
            if ($SN -ge 10) {
                $half = $SN / 2
                $newLeft = [int64][Math]::Floor($half)
                $newRight = [int64][Math]::Ceiling($half)
                #Write-Verbose "split $SN into $($newLeft | ConvertTo-Json -Comp -Dep 10),$($newRight | ConvertTo-Json -Comp -Dep 10)"
                return $true,@($newLeft,$newRight)
            }
            return $false,$SN
        }

        $a,$b = $SN

        # recurse left
        $change,$a = Invoke-Split $a
        if ($change) {
            return $true,@($a,$b)
        }

        # recurse right
        $change,$b = Invoke-Split $b
        return $change,@($a,$b)
    }

    function Add-SnailNumbers {
        #[CmdletBinding()]
        param($A,$B)

        #Write-Verbose "add $($A | ConvertTo-Json -Dep 10 -Comp) + $($B | ConvertTo-Json -Dep 10 -Comp)"
        $SN = @($A,$B)

        while ($true) {
            # check explosions
            $change,$null,$SN,$null = Invoke-Explode $SN
            if ($change) { continue }
            # check splits
            $change,$SN = Invoke-Split $SN
            if (-not $change) { break }
        }

        return $SN
    }

    function ConvertTo-Magnitude {
        #[CmdletBinding()]
        param($SN)

        if ($SN.Count -eq 1) {
            return $SN
        }

        3 * (ConvertTo-Magnitude $SN[0]) + 2 * (ConvertTo-Magnitude $SN[1])
    }



if (-not $Part2) {
    # Part 1
    $lines = Get-Clipboard

    $sn = $lines[0] | ConvertFrom-Json
    Write-Host "  $($sn | ConvertTo-Json -Comp -Dep 10)"
    foreach ($line in $lines[1..($lines.Count-1)]) {

        $B = $line | ConvertFrom-Json
        Write-Host "+ $($B | ConvertTo-Json -Comp -Dep 10)"
        $script:Explode=$script:Split=$script:Add=$script:AddSN=$script:Mag=0
        $ts = measure-command { $sn = Add-SnailNumbers $sn $B }
        Write-Verbose "add took $($ts.TotalMilliseconds) ms, $($script:Explode) $($script:Split) $($script:Add) function calls"
        Write-Host "= $($sn | ConvertTo-Json -Dep 10 -Comp)"
    }
    measure-command { $mag = ConvertTo-Magnitude $sn } | % TotalMilliseconds
    Write-Host "Part 1: $mag"

}
else {
    # Part 2
    $lines = Get-Clipboard

    # create permutations of the inputs
    $snailNums = foreach ($a in $lines) {
        foreach ($b in ($lines | ?{ $_ -ne $a })) {
            ,(Add-SnailNumbers ($a | ConvertFrom-Json) ($b | ConvertFrom-Json))
        }
    }
    Write-Verbose "$($snailNums.Count) resulting numbers"

    # calculate the magnitues of all of them and output the largest
    $mags = foreach ($sn in $snailNums) {
        ConvertTo-Magnitude $sn
    }
    $mags | sort -desc | select -first 1
}
