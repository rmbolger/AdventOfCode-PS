#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d7.txt'
)

# https://adventofcode.com/2022/day/7

    # helper that returns the parent path of a given folder
    function UpDir {
        param([string]$dir)
        $dir = $dir.Substring(0,$dir.LastIndexOf('/'))
        return ($dir -eq '') ? '/' : $dir
    }

    # parse the file structure into a hashtable where each absolute
    # folder path is a key its value is a list of file details
    $fs = @{}
    switch -Regex (Get-Content $InputFile) {

        # change directory
        '\$ cd (\S+)' {
            if ($matches[1] -eq '/') {
                $curDir = '/'
            }
            elseif ($matches[1] -eq '..') {
                $curDir = UpDir $curDir
            }
            else {
                $curDir += ($curDir -eq '/') ? $matches[1] : "/$($matches[1])"
            }

            # add the current dir to the hashtable if it doesn't exist
            if ($null -eq $fs[$curDir]) {
                $fs[$curDir] = 0
            }
        }

        # file
        '(\d+) (\S+)' {

            # add the file size to the current directory
            $fs[$curDir] += [int]$matches[1]

            # add it to all of the parent directories as well
            $tempDir = $curDir
            while ($tempDir -ne '/') {
                $tempDir = UpDir $tempDir
                $fs[$tempDir] += [int]$matches[1]
            }
        }

    }

    # Part 1
    $fs.GetEnumerator()
    | Where-Object { $_.Value -le 100000 }
    | Measure-Object -Sum Value
    | Select-Object -Expand sum

    # Part 2
    $usedSpace = $fs['/']
    $needed = 30000000 - (70000000 - $usedSpace)
    $fs.GetEnumerator()
    | Where-Object { $_.Value -ge $needed }
    | Sort-Object Value
    | Select-Object -First 1 -Expand Value
