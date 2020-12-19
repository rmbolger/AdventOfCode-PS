[CmdletBinding()]
param(
    [string]$InputFile = '.\d19.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$data = ((Get-Content $InputFile -Raw) -split "`n`n").Trim()
$global:ruleLines = $data[0] -split "`n"
$messages = $data[1] -split "`n"

# rules come in 3 forms
# - "a" or "b"
# - 1+ numbers
# - 1+ numbers | 1+ numbers

$rules = @{}
switch -Regex ($ruleLines) {
    '(?<num>\d+): "(?<letter>a|b)"' {
        $rules[[int]$matches.num] = $matches.letter
    }
    '(?<num>\d+): (?<rule>[0-9 |]+)' {
        $rules[[int]$matches.num] = $matches.rule
    }
}


function BuildRegex {
    [CmdletBinding()]
    param(
        [string]$r
    )

    #Write-Verbose "parse: $r"

    if ($r -in 'a','b') { return $r }

    if ($r.IndexOf('|') -gt 0) {
        $sides = $r.Split('|').Trim()
        $template = '(?:{0}|{1})'
        $left = BuildRegex $sides[0]
        $right = BuildRegex $sides[1]
        $parsed = $template -f $left,$right
        #Write-Verbose "returning $parsed"
        return $parsed
    }

    # anything left should be one or more space separated
    # numbers
    [int[]]$vals = $r -split ' '
    $parsed = ''
    foreach ($x in $vals) {
        # if ($x -eq 8) {
        #     if ($hit8) { Write-Verbose "skipped 8"; continue }
        #     else { Write-Verbose "hit 8"; $hit8 = $true }
        # }
        # if ($x -eq 11) {
        #     if ($hit11) { Write-Verbose "skipped 11"; continue }
        #     else { Write-Verbose "hit 11"; $hit11 = $true }
        # }
        $result = BuildRegex $rules[$x]
        $parsed += $result
        if ($x -eq 42) { $parsed += '{2,}' }
        if ($x -eq 31) { $parsed += '+' }
    }
    #Write-Verbose "returning $parsed"
    return $parsed
}


# Part 1
if (-not $NoPart1) {

    $re = [regex]"^$(BuildRegex $rules[0])$"
    $valid = $messages | ?{ $_ -match $re }
    Write-Host $valid.Count

}



# Part 2
if (-not $NoPart2) {

    #$rules[8] = '42 | 42 8'
    #$rules[11] = '42 31 | 42 11 31'
    $rules[11] = '31'
    # $hit8 = $false
    # $hit11 = $false
    $re = [regex]"^$(BuildRegex $rules[0])$"
    $re.ToString()
    $valid = $messages | ?{ $_ -match $re }
    Write-Host $valid.Count

    # 355 is wrong (too high)

}

<#
(?:(?:b(?:a(?:bb|ab)|b(?:a|b)(?:a|b))|a(?:bbb|a(?:bb|a(?:a|b))))b|(?:(?:(?:aa|ab)a|bbb)b|(?:(?:a|b)a|bb)aa)a)
(?:(?:b(?:a(?:bb|ab)|b(?:a|b)(?:a|b))|a(?:bbb|a(?:bb|a(?:a|b))))b|(?:(?:(?:aa|ab)a|bbb)b|(?:(?:a|b)a|bb)aa)a)+
(?:(?:b(?:a(?:bb|ab)|b(?:a|b)(?:a|b))|a(?:bbb|a(?:bb|a(?:a|b))))b|(?:(?:(?:aa|ab)a|bbb)b|(?:(?:a|b)a|bb)aa)a)
(?:b(?:b(?:aba|baa)|a(?:b(?:ab|(?:a|b)a)|a(?:ba|ab)))|a(?:b(?:(?:ab|(?:a|b)a)b|(?:(?:a|b)a|bb)a)|a(?:bab|(?:ba|bb)a)))


^(?:(?:b(?:a(?:bb|ab)|b(?:a|b)(?:a|b))|a(?:bbb|a(?:bb|a(?:a|b))))b|(?:(?:(?:aa|ab)a|bbb)b|(?:(?:a|b)a|bb)aa)a)+(?:b(?:b(?:aba|baa)|a(?:b(?:ab|(?:a|b)a)|a(?:ba|ab)))|a(?:b(?:(?:ab|(?:a|b)a)b|(?:(?:a|b)a|bb)a)|a(?:bab|(?:ba|bb)a)))+$
^(?:(?:b(?:a(?:bb|ab)|b(?:a|b)(?:a|b))|a(?:bbb|a(?:bb|a(?:a|b))))b|(?:(?:(?:aa|ab)a|bbb)b|(?:(?:a|b)a|bb)aa)a){2,}(?:b(?:b(?:aba|baa)|a(?:b(?:ab|(?:a|b)a)|a(?:ba|ab)))|a(?:b(?:(?:ab|(?:a|b)a)b|(?:(?:a|b)a|bb)a)|a(?:bab|(?:ba|bb)a)))+$

^(?:a(?:(?:(?:a(?:(?:b(?:aa|b(?:b|a))|a(?:b|a)(?:b|a))b|(?:b(?:aa|ab)|a(?:aa|bb))a)|b(?:b(?:(?:ab|(?:b|a)a)a|(?:aa|ab)b)|a(?:a(?:ba|(?:b|a)b)|b(?:aa|bb))))b|(?:(?:(?:ba|bb)bb|(?:b(?:ab|(?:b|a)a)|a(?:aa|b(?:b|a)))a)b|(?:(?:(?:aa|ab)b|(?:aa|b(?:b|a))a)a|(?:ba|bb)ab)a)a)a|(?:b(?:b(?:(?:b(?:ba|bb)|a(?:bb|a(?:b|a)))a|(?:(?:aa|bb)a|(?:ab|(?:b|a)a)b)b)|a(?:(?:bab|(?:ba|bb)a)b|(?:(?:bb|a(?:b|a))a|bab)a))|a(?:b(?:(?:b(?:aa|b(?:b|a))|a(?:bb|a(?:b|a)))a|(?:ba|bb)(?:b|a)b)|a(?:(?:bba|a(?:ba|bb))b|(?:(?:aa|b(?:b|a))a|abb)a)))b)|b(?:a(?:(?:a(?:(?:ba|bb)aa|(?:a(?:ba|ab)|bba)b)|b(?:(?:aaa|b(?:bb|a(?:b|a)))a|(?:b(?:aa|ab)|aab)b))a|(?:a(?:b(?:b|a)(?:ab|(?:b|a)a)|a(?:(?:aa|bb)a|(?:aa|b(?:b|a))b))|b(?:(?:(?:bb|a(?:b|a))a|bab)a|(?:aaa|(?:bb|a(?:b|a))b)b))b)|b(?:(?:b(?:a(?:bab|aba)|b(?:b(?:ba|(?:b|a)b)|a(?:aa|b(?:b|a))))|a(?:abaa|b(?:b(?:ba|bb)|aba)))b|(?:a(?:(?:aba|(?:bb|a(?:b|a))b)b|(?:(?:ab|(?:b|a)a)a|bab)a)|b(?:a(?:(?:bb|ab)b|(?:ba|bb)a)|b(?:a(?:bb|ab)|bba)))a))){2,}(?:b(?:b(?:(?:(?:(?:aba|bbb)b|(?:(?:ab|(?:b|a)a)a|(?:ba|(?:b|a)b)b)a)b|(?:(?:(?:aa|ab)b|(?:aa|b(?:b|a))a)b|(?:(?:bb|ab)b|(?:ba|bb)a)a)a)a|(?:(?:a(?:(?:aa|ab)b|(?:aa|b(?:b|a))a)|b(?:bba|a(?:aa|b(?:b|a))))a|(?:b(?:a(?:bb|a(?:b|a))|baa)|a(?:(?:b|a)(?:b|a)a|(?:ab|(?:b|a)a)b))b)b)|a(?:(?:(?:(?:bba|a(?:aa|b(?:b|a)))b|(?:(?:ba|bb)b|bba)a)b|(?:(?:aab|bba)a|(?:aaa|b(?:bb|a(?:b|a)))b)a)b|(?:(?:b(?:(?:bb|ab)a|(?:aa|ab)b)|a(?:a(?:b|a)(?:b|a)|b(?:bb|ab)))a|(?:(?:(?:b|a)(?:b|a)b|aba)b|(?:(?:ab|(?:b|a)a)a|(?:ba|bb)b)a)b)a))|a(?:(?:(?:b(?:(?:b(?:ba|bb)|aba)b|(?:aaa|(?:bb|ab)b)a)|a(?:(?:b(?:ba|bb)|a(?:ba|ab))a|babb))b|(?:(?:a(?:(?:b|a)(?:b|a)b|aba)|b(?:b(?:ba|ab)|aab))b|(?:(?:a(?:b|a)(?:b|a)|b(?:bb|ab))b|(?:(?:ba|bb)b|aba)a)a)a)a|(?:a(?:(?:(?:(?:ab|(?:b|a)a)a|bab)a|(?:(?:ba|ab)b|(?:ab|(?:b|a)a)a)b)b|(?:a(?:aba|(?:aa|b(?:b|a))b)|b(?:bab|aba))a)|b(?:(?:(?:aaa|(?:bb|a(?:b|a))b)b|(?:a(?:aa|ab)|b(?:ba|ab))a)b|(?:b(?:aba|b(?:aa|ab))|a(?:baa|(?:bb|a(?:b|a))b))a))b))+$
#>
