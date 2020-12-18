[CmdletBinding()]
param(
    [string]$InputFile = '.\d18.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

$lines = (Get-Content $InputFile).Trim()

$reParens = [regex]'\(([^)(]+)\)'
$reSimpleOp = [regex]'(\d+ (\+|\*) \d+)'

# Part 1
if (-not $NoPart1) {

    function SpecialMath {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline)]
            [string]$exp
        )

        Process {
            $orig = $exp

            # recursively evaluate the parenthesis expressions
            #Write-Verbose $exp
            while ($exp -match $reParens) {
                $result = SpecialMath $matches[1]
                $exp = $exp.Replace($matches[0], $result)
                #Write-Verbose $exp
            }

            # now there should be no more parens, so just eval
            # left to right by parsing each op pair with regex
            while ($exp -match $reSimpleOp) {
                $result = $matches[0] | iex
                $exp = $exp.Replace($matches[0], $result)
                #Write-Verbose $exp
            }

            #try {
                [long]$exp
            #} catch { Write-Warning $orig }
        }

    }

    #$lines[0] | SpecialMath
    $results = $lines | SpecialMath
    Write-Verbose "$($lines.Count) lines"
    Write-Verbose "$($results.Count) results"
    $results | sort
    $answer = ($results | Measure -Sum).Sum
    #Write-Host $answer

    # 45283905003863 is wrong

}


# Part 2
if (-not $NoPart2) {


}
