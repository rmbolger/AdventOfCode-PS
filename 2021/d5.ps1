#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d5.txt'
)

# https://adventofcode.com/2021/day/5

$data = Get-Content $InputFile
Set-Clipboard $data

    function Get-Points {
        [CmdletBinding()]
        param(
            [object[]]$Coords
        )

        foreach ($c in $Coords) {
            Write-Verbose ($c -join ',')

            # enumerate the points between x1,y1 and x2,y2
            $x,$y = $c[0],$c[1]
            do {
                "$x,$y"
                # increment/decrement x and y if they're not already done
                if ($x -ne $c[2]) { $x += ($c[0] -le $c[2]) ? 1 : -1 }
                if ($y -ne $c[3]) { $y += ($c[1] -le $c[3]) ? 1 : -1 }
            }
            while ($x -ne $c[2] -or $y -ne $c[3])

            # don't forget the last point
            "$x,$y"
        }
    }

    # parse the input
    $coords = gcb | %{
        ,[int[]](($_.Replace(' -> ',',')) -split ',')
    }

    # separate the diagonals and non-diagonals
    $nonDiags = $coords | Where-Object {
        $_[0] -eq $_[2] -or $_[1] -eq $_[3]
    }
    $diags = $coords | Where-Object {
        $_[0] -ne $_[2] -and $_[1] -ne $_[3]
    }

# Part 1

    $points = Get-Points $nonDiags
    ($points |
        Group-Object |
        Where-Object { $_.Count -gt 1 } |
        Measure-Object
    ).Count

# Part 2

    $points += Get-Points $diags
    ($points |
        Group-Object |
        Where-Object { $_.Count -gt 1 } |
        Measure-Object
    ).Count



# u/bis implementation using encoded int keys and dictionary
# $1=[System.Collections.Generic.Dictionary[int,int]]::new(1000)
# $2=[System.Collections.Generic.Dictionary[int,int]]::new(1000)
# gcb|%{
#   $x1,$y1,$x2,$y2=$_-split'\D+'-as[int[]]
#   $x=$x1..$x2
#   $y=$y1..$y2
#   $c=$x.Count
#   if($y1-eq$y2){
#     $x|%{$1[$_*1000+$y1]++}
#     $y*=$c
#   }
#   elseif($x1-eq$x2){
#     $y|%{$1[$x1*1000+$_]++}
#     $c=$y.Count
#     $x*=$c
#   }
#   0..($c-1)|%{$2[$x[$_]*1000-$y[$_]]++}
# }
# ($1.Values-gt1).Count
# ($2.Values-gt1).Count
