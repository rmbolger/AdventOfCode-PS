[CmdletBinding()]
param(
    [string]$InputFile = '.\d18.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    $lines = (Get-Content $InputFile).Trim()

    $reParens = [regex]'\(([^)(]+)\)'
    $reSimpleOp = [regex]'(\d+ (\+|\*) \d+)'
    $reAddOp = [regex]'(\d+ \+ \d+)'

    function SpecialMath {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline)]
            [string]$exp,
            [switch]$Part2
        )

        Process {
            $orig = $exp

            # recursively evaluate the anything within a pair of ()'s
            Write-Verbose $exp
            while ($exp -match $reParens) {
                $result = SpecialMath $matches[1] -Part2:$Part2.IsPresent
                $reTemp = [regex]::new([regex]::Escape($matches[0]))
                $exp = $reTemp.Replace($exp, $result, 1)
                Write-Verbose $exp
            }

            if ($Part2) {
                # eval all the additions first
                while ($exp -match $reAddOp) {
                    $result = $matches[0] | iex
                    $reTemp = [regex]::new([regex]::Escape($matches[0]))
                    $exp = $reTemp.Replace($exp, $result, 1)
                    Write-Verbose $exp
                }

                # all that's left should be multiplication or a single
                # number so eval the whole thing and return early
                $result = $exp | iex
                Write-Verbose $result
                return [long]$result
            }

            # eval the rest left to right by parsing each op pair
            while ($exp -match $reSimpleOp) {
                $result = $matches[0] | iex
                $reTemp = [regex]::new([regex]::Escape($matches[0]))
                $exp = $reTemp.Replace($exp, $result, 1)
                Write-Verbose $exp
            }

            [long]$exp
        }

    }

    # Alternative solution using PowerShell class and operator overloading
    class N {
        [long]$Value = 0

        N() {}

        N([long]$Value) {
            $this.Value = $Value
        }

        [long] GetValue() {
            return $this.Value
        }

        static [N] op_Addition([N]$Left, [N]$Right) {
            return [N]::new($Left.GetValue() + $Right.GetValue())
        }

        # Multiply
        static [N] op_Subtraction([N]$Left, [N]$Right) {
            return [N]::new($Left.GetValue() * $Right.GetValue())
        }

        # Addition
        static [N] op_Multiply([N]$Left, [N]$Right) {
            return [N]::new($Left.GetValue() + $Right.GetValue())
        }
    }

# Part 1
if (-not $NoPart1) {

    $results = $lines | SpecialMath

    # # Alternate solution
    # $results = foreach ($line in $lines) {
    #     $l = $line.Replace('*', '-')
    #     $l = $l -replace '(\d+)', '[N]::new($1)'
    #     (Invoke-Expression $l).Value
    # }

    Write-Host ($results | Measure -Sum).Sum

}


# Part 2
if (-not $NoPart2) {

    $results = $lines | SpecialMath -Part2

    # # Alternate solution
    # $results = foreach ($line in $lines) {
    #     $l = $line.Replace('*', '-').Replace('+', '*')
    #     $l = $l -replace '(\d+)', '[N]::new($1)'
    #     (Invoke-Expression $l).Value
    # }

    Write-Host ($results | Measure -Sum).Sum

}
