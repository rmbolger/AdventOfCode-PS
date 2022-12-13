#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d13.txt'
)

# https://adventofcode.com/2022/day/13

$pairs = (Get-Content $InputFile -Raw).Trim() -split "`n`n"

function IsDigit {
    param([int]$charCode)
    # digits include ':'(58) representing 10 because it comes
    # after '9' in ASCII
    $charCode -ge 48 -and $charCode -le 58
}
function CodeToStr {
    param([int]$charCode)
    return (($charCode -eq 58) ? '10' : ([char]$charCode))
}

class Packet : IComparable
{
    [Collections.Generic.List[int]]$lList
    [string]$origString

    Packet([string]$packet) {
        $this.origString = $packet
        # The numbers in a packet range from 1-10 with 10 being the only
        # 2-digit number which makes doing char-by-char comparisons
        # harder. But we can replace "10" with ":" because it comes after
        # "9" in the ASCII table and convert the chars to their int char
        # codes. Then, the "char"-by-"char" comparisons are easy.
        $this.lList = [Collections.Generic.List[int]]::new(
            [int[]]$packet.Replace('10',':').ToCharArray()
        )
    }

    [int]CompareTo([object]$rPacket) {
        if ($rPacket -isnot [Packet]) {
            throw [ArgumentException]::new('right')
        }
        $rList = $rPacket.lList

        # return -1 if left is "smaller"
        # return 0 if left and right equal
        # return 1 if right is "smaller"

        # make nice variables for the brackets we'll be referencing
        # in conditionals so things are easier to read
        $open  = 91 # [
        $close = 93 # ]

        for ($i=1; $i -lt [Math]::Min($this.lList.Count,$rList.Count); $i++) {

            # get current character
            $left  = $this.lList[$i]
            $right = $rList[$i]

            # move forward if same
            if ($left -eq $right) { continue }

            # compare if both are numbers
            if ((IsDigit $left) -and (IsDigit $right)) {
                #Write-Verbose "compare $(CodeToStr $left) vs $(CodeToStr $right)"
                if ($left -lt $right) {
                    #Write-Verbose "GOOD - left smaller"
                    return -1
                } else {
                    #Write-Verbose "BAD - right smaller"
                    return 1
                }
            }

            # check if left or right are digits needing brackets
            if ($right -eq $open -and (IsDigit $left)) {
                $this.lList.Insert($i+1, $close)
                $this.lList.Insert($i, $open)
                continue
            }
            if ($left -eq $open -and (IsDigit $right)) {
                $rList.Insert($i+1, $close)
                $rList.Insert($i, $open)
                continue
            }

            # check if left or right ran out
            if ($left -eq $close -and $right -ne $close) {
                #Write-Verbose "GOOD - left ran out"
                return -1
            }
            if ($right -eq $close -and $left -ne $close) {
                #Write-Verbose "BAD - right ran out"
                return 1
            }

            Write-Warning "uncaught condition at index $i, left $(CodeToStr $left) right $(CodeToStr $right)"
        }

        Write-Warning "nothing should be equal"
        return 0
    }

    [string]ToString() {
        return $this.origString
    }
}

# Part 1

$indices = foreach ($pIndex in (1..$pairs.Count)) {
    $lRaw,$rRaw = $pairs[$pIndex] -split "`n"
    if ([Packet]$lRaw -lt [Packet]$rRaw) {
        $pIndex
    }
}
($indices | Measure-Object -Sum).Sum

# Part 2

# get the unsorted list of packets
$packets = foreach ($pair in $pairs) {
    $lRaw,$rRaw = $pair -split "`n"
    [Packet]::new($lRaw)
    [Packet]::new($rRaw)
}

# add the dividers and sort
$packets += @([Packet]'[[2]]',[Packet]'[[6]]')
$packets = $packets | Sort-Object

# calculate the decoder key
$decoderKey = 1
for ($i=0; $i -lt $packets.Count; $i++) {
    #Write-Verbose $packets[$i].ToString()
    if ($packets[$i] -in '[[2]]','[[6]]') {
        $decoderKey *= ($i+1)
    }
}
$decoderKey
