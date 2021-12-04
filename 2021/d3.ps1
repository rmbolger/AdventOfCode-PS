#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d3.txt'
)

# https://adventofcode.com/2021/day/3

$diags = Get-Content $InputFile
Set-Clipboard $diags

# Part 1

    # split our list of strings into a list of char arrays
    $diags = Get-Clipboard | %{ ,[char[]]$_ }

    # count 1s in each position
    $ones = @(0,0,0,0,0,0,0,0,0,0,0,0)
    foreach ($chars in $diags) {
        0..11 | %{
            $ones[$_] += [string]$chars[$_]
        }
    }
    Write-Verbose ($ones -join ' ')

    # build gamma
    $countHalf = $diags.Count / 2
    $gammaPieces = 0..11 | %{
        ($countHalf -lt $ones[$_]) ? '1' : '0'  # PS7+ Ternary
    }
    Write-Verbose ($gammaPieces -join ' ')

    # convert binary string to int
    $gamma = [Convert]::ToInt32(($gammaPieces -join ''),2)

    # epsilon is just inverted gamma
    # input lines are 12 bits so -bxor 4095 (00000000000000000000111111111111) to invert
    $epsilon = $gamma -bxor 4095
    $gamma * $epsilon


# Part 2

    # split our list of strings into a list of char arrays
    $diags = Get-Clipboard | %{ ,[char[]]$_ }

    function Get-CommonValue {
        [CmdletBinding()]
        param(
            [object[]]$diags,
            [int]$Bit,
            [switch]$LeastCommon
        )

        # count ones in this position
        $oneCount = 0
        $diags | %{
            $oneCount += [string]$_[$Bit]
        }

        # decide which to keep depending on Most or Least common
        $countHalf = $diags.Count / 2
        if ($LeastCommon) {
            $keep = ($countHalf -le $oneCount) ? '0' : '1'
        } else {
            $keep = ($countHalf -le $oneCount) ? '1' : '0'
        }

        # filter the inputs
        $filtered = @($diags | ?{ $_[$Bit] -eq $keep })
        Write-Verbose "Bit $Bit : half $countHalf, oneCount $oneCount, keep $keep, filteredCount $($filtered.Count)"

        # recurse with the filtered results on the next position or return
        if ($filtered.Count -gt 1) {
            Write-Verbose "recurse"
            Get-CommonValue $filtered ($Bit+1) -LeastCommon:$LeastCommon.IsPresent
        } else {
            Write-Verbose "returning $($filtered[0] -join '')"
            $filtered[0] -join ''
        }
    }

    # get most common val for oxy and least common for co2
    $oxyStr = Get-CommonValue $diags 0
    $co2Str = Get-CommonValue $diags 0 -LeastCommon
    Write-Verbose "oxy $oxyStr, co2 $co2Str"

    # binary to int and multiply
    [Convert]::ToInt32($oxyStr,2) * [Convert]::ToInt32($co2Str,2)


# Part 1 messing around

# # split rows into objects with each char in a column named for its index
# $data = gcb | %{
#     $line=$_
#     $ret = @{}
#     0..($line.Length-1) | %{
#         $ret.$_ = $line[$_]
#     }
#     [pscustomobject]$ret
# }

# $data

# u/bis's as-posted answer
# $c=@{}
# $g=$e=0
# ($L=gcb|?{$_})|%{$b=echo @_;($r=0..($b.Count-1))|%{$c[$_*2+$b[$_]-48]++}}
# $r|%{$x=$c[$_*2]-lt$c[$_*2+1];$g*=2;$e*=2;$g+=$x;$e+=1-$x}
# $g*$e
# for($i,$x=0,$L,@($L);$x[0][1]-or$x[1][1];$i++){0,1|%{$x[$_]=($x[$_]|group{$_[$i]}|sort Count, Name)[$_].Group}}
# ($x|%{$_}|%{$n=0;echo @_|%{$n=$n*2+$_%2};$n})-join'*'|iex

# Verbose'ified version u/bis's answer

    $inputs = Get-Clipboard | Where-Object {$_} # make sure no empty lines

    # Part 1

    $counts = @{}
    $gam = $eps = 0
    $range = 0..($inputs[0].Length-1)   # set of bit positions for our puzzle input

    $inputs | ForEach-Object {      # loop through the inputs
        $chars = Write-Output @_    # make line into char array by abusing splatting
        $range | ForEach-Object {   # loop through the bit positions
            # convert the char in this position to its int value by subtracting
            # the ASCII '0' value of 48
            $val = $chars[$_] - 48
            # create a unique key for each bit index and value combination
            $key = ($_ * 2) + $val
            # increment the count for the key
            $counts[$key]++
        }
    }
    $range | ForEach-Object {
        # build the two possible hashtable keys for this bit position
        $key0 = $_ * 2
        $key1 = $_ * 2 + 1
        # determine the most common value by abusing True=1/False=0
        $comval = $counts[$key0] -lt $counts[$key1]
        # shift the bits left to make room for the next value
        # (could also use -shl 1, but *= 2 is shorter)
        $gam *= 2
        $eps *= 2
        # add the appropriate value to each rate
        $gam += $comval
        $eps += 1 - $comval
    }
    $gam*$eps

    # Part 2

    # $i loops through the bit positions
    # $x holds two copies of the input data that will each be filtered
    # in each loop based on the least ($x[0]) and most ($x[1]) common value at
    # each position. Keep looping until both lists have only 1 entry (e.g. null
    # second index).
    for ($i,$x=@(0,@($inputs),@($inputs)); $x[0][1] -or $x[1][1]; $i++) {
        0,1 | ForEach-Object {              # 0 = least common list, 1 = most common list
            $x[$_] = ($x[$_] |              # filter the current list
                Group-Object { $_[$i] } |   # group by the character at the current bit position
                Sort-Object Count,Name      # sort by the Count so least common is first
                                            # and Name deterministically breaks ties
            )[$_].Group                     # pick the appropriate filtered list
        }
        Write-Verbose "Position $i : x =`n$($x | ConvertTo-Json)"
    }

    # Now have to multiply our two values that are currently binary strings

    # In PS7+ we have the "0b" numeric literal prefix that we can attach to the
    # existing strings and then abuse Invoke-Expression to multiply them.
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_numeric_literals
    $strValues = $x | ForEach-Object { "0b$_" }
    $strValues -join '*' |  # e.g. "0b01010*0b10111"
        Invoke-Expression

    # In PS5 if we still want to abuse Invoke-Expression, we need to do more
    # work to actually do that by writing our own bin->int algorithm...assuming
    # we forgot about [Convert]::ToInt32('10101',2)) or maybe it's more characters
    # when golfing?
    $values = $x | ForEach-Object {$_} | ForEach-Object { # loop through both values
        $n=0
        Write-Output @_ | ForEach-Object {  # loop through the characters in each value
            # ($n * 2) effectively shifts the current bits to the left allowing space
            # add the next bit
            # ($_ % 2) effectively converts the char value to int
            # because '0' is ASCII 48 and '1' is ASCII 49
            $n = ($n * 2) + ($_ % 2)
        }
        $n
    }
    # even though the values are already [int] and we could just multiply them
    # directly, abusing Invoke-Expression is fewer characters when golfing an
    # answer using its alias 'iex'
    $values -join '*' |     # e.g. "10*23"
        Invoke-Expression
