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
