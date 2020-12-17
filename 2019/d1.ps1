[CmdletBinding()]
param(
    [string]$InputFile = '.\d1.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

[int[]]$masses = Get-Content $InputFile

# Part 1
if (-not $NoPart1) {

    ($masses | ForEach-Object {
        [Math]::Floor($_/3) - 2
    } | measure -sum).Sum

}

# Part 2
if (-not $NoPart2) {

    ($masses | ForEach-Object {
        $mass = 0;
        $fuel = $_;
        while ($fuel -gt 0) {
            $fuel = [Math]::Floor($fuel/3) - 2
            if ($fuel -gt 0) {
                Write-Verbose "$($mass+$fuel) = $mass + $fuel"
                $mass += $fuel
            }
        }
        $mass
    } | measure -sum).Sum

}
