<#
    .SYNOPSIS
    A simple visualization of Advent of Code 2021 - Day 8 part 2

    .EXAMPLE
    Get-Content .\d8.txt | .\d8-viz.ps1

    Run visualization from input file

    .EXAMPLE
    Get-Clipboard | .\d8-viz.ps1

    Run visualization from clipboard input
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$SignalLine
)

Begin {
    # pre-"render" all of the digits in a way that makes them easy
    # to concatenate
    $digits = @{
        '0' = @(
            '   #### '
            '  #    #'
            '  #    #'
            '        '
            '  #    #'
            '  #    #'
            '   #### '
        )
        '1' = @(
            '        '
            '       #'
            '       #'
            '        '
            '       #'
            '       #'
            '        '
        )
        '2' = @(
            '   #### '
            '       #'
            '       #'
            '   #### '
            '  #     '
            '  #     '
            '   #### '
        )
        '3' = @(
            '   #### '
            '       #'
            '       #'
            '   #### '
            '       #'
            '       #'
            '   #### '
        )
        '4' = @(
            '        '
            '  #    #'
            '  #    #'
            '   #### '
            '       #'
            '       #'
            '        '
        )
        '5' = @(
            '   #### '
            '  #     '
            '  #     '
            '   #### '
            '       #'
            '       #'
            '   #### '
        )
        '6' = @(
            '   #### '
            '  #     '
            '  #     '
            '   #### '
            '  #    #'
            '  #    #'
            '   #### '
        )
        '7' = @(
            '   #### '
            '       #'
            '       #'
            '        '
            '       #'
            '       #'
            '        '
        )
        '8' = @(
            '   #### '
            '  #    #'
            '  #    #'
            '   #### '
            '  #    #'
            '  #    #'
            '   #### '
        )
        '9' = @(
            '   #### '
            '  #    #'
            '  #    #'
            '   #### '
            '       #'
            '       #'
            '   #### '
        )
    }

    function Get-SignalViz {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory,ValueFromPipeline)]
            [string]$SignalLine
        )
        Process {

            # parse the scrambled digits
            $allDigits = $SignalLine -split '\W+' | %{
                # sort each digit's letters so they're consistent
                # between instances in this set
                ,($_[0..($_.Length-1)] | Sort-Object)
            }
            $patterns = $allDigits[0..9] | Sort-Object { $_.Count }
            $fives = $patterns | ?{ $_.Count -eq 5 }
            $sixes = $patterns | ?{ $_.Count -eq 6 }
            $output = $allDigits[10..13] | %{ $_ -join '' }

            # start a decoder
            $decode = @{}
            # add the uniques
            $patterns | %{
                $s = $_ -join ''
                    if ($_.Count -eq 2) { $decode.$s = '1'; $1 = $_ }
                elseif ($_.Count -eq 3) { $decode.$s = '7'; $7 = $_ }
                elseif ($_.Count -eq 4) { $decode.$s = '4'; $4 = $_ }
                elseif ($_.Count -eq 7) { $decode.$s = '8'; $8 = $_ }
            }

            # 3 = Length 5 that contains 1's characters
            $fives = $fives | %{
                if ($1[0] -in $_ -and $1[1] -in $_) { $3 = $_ }
                else { ,$_ }
            }
            $decode.($3-join'') = '3'

            # 6 = Length 6 that does not contain 1's characters
            $sixes = $sixes | %{
                if ($1[0] -notin $_ -or $1[1] -notin $_) { $6 = $_ }
                else { ,$_ }
            }
            $decode.($6-join'') = '6'

            # 5 = Length 5 that only diff 6 by one letter
            # 2 = Remaining Length 5
            if ((Compare-Object $6 $fives[0]).Count -eq 1) {
                $5 = $fives[0]
                $2 = $fives[1]
            } else {
                $2 = $fives[0]
                $5 = $fives[1]
            }
            $decode.($5-join'') = '5'
            $decode.($2-join'') = '2'

            # 9 = Length 6 that only diff (Unique 4+7) by one letter
            # 0 = Remaining Length 6
            $47 = $4 + $7 | Sort-Object -Unique
            if ((Compare-Object $47 $sixes[0]).Count -eq 1) {
                $9 = $sixes[0]
                $0 = $sixes[1]
            } else {
                $0 = $sixes[0]
                $9 = $sixes[1]
            }
            $decode.($9-join'') = '9'
            $decode.($0-join'') = '0'

            # return the set of strings to visualize the output
            $ret = @(' ==================================')
            0..6 | %{
                $ret += '|{0}{1}{2}{3}  |' -f
                    $digits[$decode[$output[0]]][$_],
                    $digits[$decode[$output[1]]][$_],
                    $digits[$decode[$output[2]]][$_],
                    $digits[$decode[$output[3]]][$_]
            }
            $ret += ' =================================='
            ,$ret
        }
    }

}

Process {

    $SignalLine | Get-SignalViz | %{
        Clear-Host
        $_
        Start-Sleep -Milliseconds 500
    }

}
