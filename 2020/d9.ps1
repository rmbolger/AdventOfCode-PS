[CmdletBinding()]
param(
    [string]$InputFile = '.\d9.txt',
    [int]$window = 25,
    [switch]$NoPart2
)

    # make sure you set this to 5 if you're using the sample data
    #$window = 25

    # convert the input to [long] values because those
    # numbers towards the end are bigger than [int]
    [long[]]$cipher = Get-Content $InputFile

    # since we'll be referencing it a few times, grab the highest
    # index from the cipher list
    $iMax = $cipher.Count - 1


# Part 1

    $part1 = foreach ($i in ($window..$iMax)) {
        $iVal = $cipher[$i]
        $adds = $cipher[($i-$window)..($i-1)]
        $hasPair = foreach ($a in $adds) {
            $b = $adds | ?{ $_ -ne $a -and ($a + $_) -eq $iVal }
            if ($b) {
                Write-Verbose "$iVal = $a + $b"
                $true; break
            }
        }
        if (-not $hasPair) {
            Write-Verbose "No pair found for $iVal"
            $iVal; break
        }
    }
    Write-Host "Part 1: $part1"


# Part 2
if (-not $NoPart2) {

    # slow brute force
    # $part2 = foreach ($start in (0..$iMax)) {
    #     $found = foreach ($end in (($start+1)..$iMax)) {
    #         $sum = ($cipher[$start..$end] | measure -sum).Sum
    #         Write-Verbose "$sum = $($cipher[$start..$end] -join '+')"
    #         if ($part1 -eq $sum) {
    #             $true
    #             $ordered = $cipher[$start..$end] | sort
    #             $weakness = $ordered[0] + $ordered[-1]
    #             Write-Verbose "Weakness $weakness = $($ordered[0]) + $($ordered[-1]) : $($ordered -join ',')"
    #             break
    #         }
    #         elseif ($sum -gt $part1) { break }
    #     }
    #     if ($found) { break }
    # }

    # # parallel brute force
    # $part2 = (0..$iMax) | ForEach-Object -ThrottleLimit 8 -Parallel {
    #     $start = $_
    #     $intCipher = $using:cipher
    #     $found = foreach ($end in (($start+1)..$using:iMax)) {
    #         $sum = ($intCipher[$start..$end] | measure -sum).Sum
    #         if ($using:part1 -eq $sum) {
    #             $true
    #             $ordered = $intCipher[$start..$end] | sort
    #             $answer = $ordered[0] + $ordered[-1]
    #             break
    #         }
    #         elseif ($sum -gt $using:part1) { break }
    #     }
    #     if ($found) { $answer; return }
    # }

    $queue = [Collections.Generic.Queue[long]]::new()
    [long]$sum=0
    $part2 = foreach ($val in $cipher) {
        $queue.Enqueue($val)
        $sum += $val
        Write-Verbose "$([char]0x2191) $sum = $($queue -join '+')"

        while ($sum -gt $part1) {
            if ($queue.Count -lt 2) {
                Write-Verbose "Not enough elements"; break
            }

            $sum -= $queue.Dequeue()
            Write-Verbose "$([char]0x2193) $sum = $($queue -join '+')"
        }
        if ($sum -eq $part1) {
            $queue | measure -min -max | %{ $_.Minimum + $_.Maximum }
            break
        }
    }

    Write-Host "Part 2: $part2"

}
