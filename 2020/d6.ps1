[CmdletBinding()]
param(
    [string]$InputFile = '.\d6.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)


# Part 1
if (-not $NoPart1) {

    $groupAnswers = ((Get-Content $InputFile -Raw) -split "`n`n" -replace "`n", '').Trim()
    $yesPerGroup = $groupAnswers | ForEach-Object {
        ($_.ToCharArray() | Sort-Object -Unique).Count
    }
    ($yesPerGroup | Measure-Object -Sum).Sum

}

# Part 2
if (-not $NoPart2) {

    $groupStrings = (Get-Content $InputFile -Delimiter "`n`n").Trim()

    # # Fun use of Compare-Object, but ultimately more complicated
    # $counts = $groupStrings | ForEach-Object {
    #     $groupAnswers = @($_ -split "`n" | %{ @(,$_.ToCharArray()) })
    #     #$groupAnswers | %{ Write-Verbose "_ $((($_ | sort) -join '')) _" }
    #     #Write-Verbose ''
    #     $common = $groupAnswers[0]
    #     $groupAnswers | ForEach-Object {
    #         if ($common.Count -eq 0) { return }
    #         $common = Compare-Object $_ $common -ExcludeDifferent -IncludeEqual -PassThru
    #         #Write-Verbose (($common | sort) -join '')
    #     }
    #     #Write-Verbose "_ $($common.Count) _"
    #     $common.Count
    # }

    $counts = $groupStrings | ForEach-Object {
        $memberCount = ($_ -split "`n").Count
        @( $_.ToCharArray() |
            Group-Object |
            Where-Object { $_.Count -eq $memberCount }
        ).Count
    }

    ($counts | Measure-Object -Sum).Sum

}
