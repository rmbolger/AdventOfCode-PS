[CmdletBinding()]
param(
    [string]$InputFile = '.\d4.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$d4 = Get-Content $InputFile

# consolidate each passport's data so there's only one line per passport
$nextStart=0
$pStrings = 0..($d4.Count-1) | ForEach-Object {
    if ($d4[$_] -eq '') {
        # join the lines we care about and return it
        $d4[$nextStart..($_-1)] -join ' '
        # set the next start line
        $nextStart = $_ + 1
    }
}
# add the last one
$pStrings += $d4[$nextStart..($d4.Count-1)] -join ' '

# alternative (dependent on the type of line endings)
# $pStrings = ((Get-Content $InputFile -Raw) -split "`r`n`r`n" -replace "`r`n", ' ').Trim()

# Part 1
if (-not $NoPart1) {
    $valid=0
    $pStrings | ForEach-Object {
        $fields = $_.Split(' ')
        if ($fields.Count -eq 8) {
            # anything with 8 is valid
            $valid++
            Write-Verbose "$_ - yes 8 - total = $valid"
        }
        elseif ($fields.Count -lt 7) {
            # less than 7 is invalid
            Write-Verbose "$_ - no few - total = $valid"
        }
        else {
            # if we're here, there are exactly 7 fields and the only one that can
            # be missing is cid
            if (-not ($fields -like 'cid:*')) {
                $valid++
                Write-Verbose "$_ - yes 7 - total = $valid"
            } else {
                Write-Verbose "$_ - no 7 - total = $valid"
            }
        }
    }
    $valid
}

# Part 2
if (-not $NoPart2) {
    # parse the passport strings into more formal objects
    $passports = $pStrings | ForEach-Object {
        $p = @{byr='';iyr='';eyr='';hgt='';hcl='';ecl='';pid='';cid=''}
        $_.Split(' ') | ForEach-Object {
            $key,$val = $_.Split(':')
            $p.$key = $val
        }
        [pscustomobject]$p
    }

    $valid = 0
    $reHeight = [regex]'^(\d+)(in|cm)$'
    $reHair = [regex]'^#[a-z0-9]{6}$'
    $reEye = [regex]'^amb|blu|brn|gry|grn|hzl|oth$'
    $rePid = [regex]'^\d{9}$'
    $passports | ForEach-Object {

        # check birth/issue/expiration year
        $byr = $_.byr -as [int]
        if (-not $byr -or $byr -lt 1920 -or $byr -gt 2002) {
            Write-Verbose "$($valid.ToString('000')) - Invalid byr($($_.byr))"
            return
        }
        $iyr = $_.iyr -as [int]
        if (-not $iyr -or $iyr -lt 2010 -or $iyr -gt 2020) {
            Write-Verbose "$($valid.ToString('000')) - Invalid iyr($($_.iyr))"
            return
        }
        $eyr = $_.eyr -as [int]
        if (-not $eyr -or $eyr -lt 2020 -or $eyr -gt 2030) {
            Write-Verbose "$($valid.ToString('000')) - Invalid eyr($($_.eyr))"
            return
        }

        # check height
        if ($_.hgt -match $reHeight) {
            # format is right, check values
            $hgt = [int]$matches[1]
            if ( -not ($matches[2] -eq 'cm' -and $hgt -ge 150 -and $hgt -le 193) -and
                -not ($matches[2] -eq 'in' -and $hgt -ge 59 -and $hgt -le 76) )
            {
                Write-Verbose "$($valid.ToString('000')) - Invalid hgt($($_.hgt))"
                return
            }
        } else {
            Write-Verbose "$($valid.ToString('000')) - Invalid hgt($($_.hgt))"
            return
        }

        # check hair/eye color
        if ($_.hcl -notmatch $reHair) {
            Write-Verbose "$($valid.ToString('000')) - Invalid hcl($($_.hcl))"
            return
        }
        if ($_.ecl -notmatch $reEye) {
            Write-Verbose "$($valid.ToString('000')) - Invalid ecl($($_.ecl))"
            return
        }

        # check passport id
        if ($_.pid -notmatch $rePid) {
            Write-Verbose "$($valid.ToString('000')) - Invalid pid($($_.pid))"
            return
        }

        $valid++
        Write-Verbose "$($valid.ToString('000')) - Valid"
    }

    $valid
}
