#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d16.txt',
    [switch]$Part2
)

# https://adventofcode.com/2021/day/16

$data = Get-Content $InputFile
Set-Clipboard $data

    # even though we could do the math conversion from hex to binary
    # it's probably quicker just to make a lookup table for each value
    $hexMap = @{
        [char]'0' = '0000'
        [char]'1' = '0001'
        [char]'2' = '0010'
        [char]'3' = '0011'
        [char]'4' = '0100'
        [char]'5' = '0101'
        [char]'6' = '0110'
        [char]'7' = '0111'
        [char]'8' = '1000'
        [char]'9' = '1001'
        [char]'A' = '1010'
        [char]'B' = '1011'
        [char]'C' = '1100'
        [char]'D' = '1101'
        [char]'E' = '1110'
        [char]'F' = '1111'
    }

    $ops = @{
        0 = @{ name='sum';  pre='(';    join='+';   suf=')' }
        1 = @{ name='prod'; pre='(';    join='*';   suf=')' }
        2 = @{ name='min';  pre='((@('; join=',';   suf=')|sort)[0])' }
        3 = @{ name='max';  pre='((@('; join=',';   suf=')|sort -desc)[0])' }
        5 = @{ name='gt';   pre='((';   join='-gt'; suf=')?1:0)' }
        6 = @{ name='lt';   pre='((';   join='-lt'; suf=')?1:0)' }
        7 = @{ name='eq';   pre='((';   join='-eq'; suf=')?1:0)' }
    }

    function ConvertFrom-Packets {
        [CmdletBinding()]
        param(
            [string]$Bits,          # the bit string
            [int]$StartIndex = 0,   # where to begin in the bit string
            [int]$ReturnAfter = 0,  # how many packets to return after
            [int]$Level=0           # cosmetic verbose indentation
        )

        $pad = '  '*$Level
        $retCount = 0

        # looping through the bits forever knowing
        # we're going to muck with $i as we go
        for ($i = $StartIndex; $i -lt $Bits.Length; ) {

            # grab the packet version/type
            $ver = [Convert]::ToInt32($Bits.Substring($i,3), 2)
            $typ = [Convert]::ToInt32($Bits.Substring($i+3,3), 2)
            $i += 6
            $script:verSum += $ver

            if ($typ -eq 4) { # literal
                # gather groups of 5 bits until one starts with 0
                $litBits = for ($j=$i; $j -lt $Bits.Length; $j+=5) {
                    $Bits.Substring($j+1,4)
                    $i += 5
                    if ($Bits[$j] -eq '0') { break }
                }
                $val = [Convert]::ToInt64($litBits -join '',2).ToString()
                $val
                $retCount++
                Write-Verbose "$pad $val    (ver $ver, total $($script:verSum))"

            } else { # operation
                Write-Verbose "$pad op $($ops[$typ].name)    (ver $ver, total $($script:verSum))"

                if ($Bits[$i] -eq '0') {
                    $subLen = [Convert]::ToInt32($Bits.Substring($i+1,15),2)
                    $i += 16
                    #Write-Verbose "$pad sub len $subLen"
                    $vals = ConvertFrom-Packets $Bits.Substring($i,$subLen) -Level ($Level+1)
                    $i += $subLen
                    #Write-Verbose "$pad $($vals.Count) vals (i=$i)"

                } else {
                    $subCount = [Convert]::ToInt32($Bits.Substring($i+1,11),2)
                    $i += 12
                    #Write-Verbose "$pad sub count $subCount (i=$i)"
                    $results = ConvertFrom-Packets $Bits -StartIndex $i -ReturnAfter $subCount -Level ($Level+1)
                    $vals = $results[0..($results.Count-2)]
                    $i = $results[-1]
                    #Write-Verbose "$pad $($vals.Count) vals (i=$i)"
                }

                # complete the expression with the results and put it on the pipeline
                $retExp = '{0}{1}{2}' -f $ops[$typ].pre,($vals -join $ops[$typ].join),$ops[$typ].suf
                $ret = $retExp | iex
                $ret.ToString()
                $retCount++
                Write-Verbose "$pad pipeline -> $ret from $retExp"
            }

            # return if we've collected enough packets
            if ($ReturnAfter -and $ReturnAfter -eq $retCount) {
                # The caller won't know how many bits we've read since
                # packets aren't all the same size. So add the updated
                # index value to the pipeline so they can grab it from
                # the returned data.
                return $i
            }

            # if remaining bytes are all 0, return
            if ($i -ge $Bits.Length -or $Bits.Substring($i) -notlike '*1*') {
                return
            }
        }
    }

    # loop through the clipboard contents in case we're testing multiple sample values
    Get-Clipboard | %{
        $nibbles = foreach ($c in $_.ToCharArray()) { $hexMap[$c] }
        $bitStr = $nibbles -join ''

        $script:verSum = 0
        $expression = ConvertFrom-Packets $bitStr

        Write-Host "Part 1: $($script:verSum)"
        Write-Host "Part 2: $expression"
    }
