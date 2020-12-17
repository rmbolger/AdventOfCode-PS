[CmdletBinding()]
param(
    [string]$InputFile = '.\d10.txt',
    [switch]$NoPart2
)

    # sort the input and grab the highest index
    $adapters = [int[]](Get-Content $InputFile) | Sort
    $iMax = $adapters.Count-1

# Part 1

    # create a collection of adapter pairs where each pair
    # contains the adapter from the sorted list and the next
    # highest including the 0 start and last+3 end
    #   0,1,4,5,6, 7,10,11,12,15,16,19
    #   1,4,5,6,7,10,11,12,15,16,19,22
    $pairs = 0..($iMax-1) | % -Begin {
        ,(0,$adapters[0])
    } -Process {
        ,($adapters[$_],$adapters[$_+1])
    } -End {
        ,($adapters[$iMax],($adapters[$iMax]+3))
    }
    #Write-Verbose "$(($pairs | %{ $_ -join ',' }) -join ' | ')"

    # In both sample data sets and my own personal dataset, the
    # differences between adapters is always 1 or 3, never 2.
    # So grouping by the difference should give us the count of
    # each to multiply.
    $diffGroups = $pairs | group { $_[1]-$_[0] }
    $diffGroups[0].Count * $diffGroups[1].Count



# Part 2
if (-not $NoPart2) {

    # PART 2
    $seqVariations = @{
        '11' = 2
        '111' = 4
        '1111' = 7
    }

    $diffSeq = ($pairs | %{ $_[1]-$_[0] }) -join ''
    Write-Verbose $diffSeq
    $g = $diffSeq -split '3' | ?{ $_ -notin '','1' } | group
    $g | % -Begin { $total = 1 } -Process {
        $total *= [Math]::Pow($seqVariations[$_.Name],$_.Count)
    }
    $total


}
