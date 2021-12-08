#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d8.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# https://adventofcode.com/2021/day/8

$data = Get-Content $InputFile
Set-Clipboard $data

# Part 1
if (-not $NoPart1) {

    # 1,4,7,8 each have uniqe char counts 2,4,3,7 respectively
    (gcb) | %{
        ($_ -split '\W+')[10..13]
    } | Where-Object {
        $_.Length -in 2,3,4,7
    } | Measure-Object | % Count

}

# Part 2
if (-not $NoPart2) {

    # Standard Letters
    # 1 =   c  f    unique  0000101 = 5
    # 4 =  bcd f    unique  0111010 = 58
    # 7 = a c  f    unique  1010010 = 82
    # 8 = abcdefg   unique  1111111 = 127
    # 2 = a cde g           1011101 = 93
    # 3 = a cd fg           1011011 = 91
    # 5 = ab d fg           1101011 = 107
    # 0 = abc efg           1110111 = 119
    # 6 = ab defg           1101111 = 111
    # 9 = abcd fg           1111011 = 123

    function Get-SignalOutput {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory,ValueFromPipeline)]
            $SignalLine
        )
        Process {

            # parse the scrambled digits
            $allDigits = $SignalLine -split '\W+' | %{
                # sort each digit's letters so they're consistent
                # between instances in this set
                ,($_[0..($_.Length-1)] | Sort-Object)
            }
            $patterns = $allDigits[0..9] | Sort-Object { $_.Count }
            Write-Verbose (($patterns|%{$_ -join ''}) -join ',')
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
            Write-Verbose "1=$($1-join''), 7=$($7-join''), 4=$($4-join''), 8=$($8-join'')"

            # 3 = Length 5 that contains 1's characters
            $fives = $fives | %{
                if ($1[0] -in $_ -and $1[1] -in $_) { $3 = $_ }
                else { ,$_ }
            }
            $decode.($3-join'') = '3'
            Write-Verbose "3=$($3-join'') - not: $(($fives|%{$_ -join ''}) -join ',')"

            # 6 = Length 6 that does not contain 1's characters
            $sixes = $sixes | %{
                if ($1[0] -notin $_ -or $1[1] -notin $_) { $6 = $_ }
                else { ,$_ }
            }
            $decode.($6-join'') = '6'
            Write-Verbose "6=$($6-join'') - not: $(($sixes|%{$_ -join ''}) -join ',')"

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
            Write-Verbose "5=$($5-join''), 2=$($2-join'')"

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
            Write-Verbose "9=$($9-join''), 0=$($0-join'')"

            # return the converted output value
            [int](($output | %{ $decode.$_ }) -join '')
        }
    }

    # pass the input to our function via the pipeline and sum the results
    gcb | Get-SignalOutput | Measure -Sum | % Sum

}
