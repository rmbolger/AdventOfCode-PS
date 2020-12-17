[CmdletBinding()]
param(
    [string]$InputFile = '.\d2.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

function RunProg {
    [CmdletBinding()]
    param(
        [string]$InputFile,
        [int]$Noun,
        [int]$Verb
    )

    [int[]]$prog = (Get-Content $InputFile -Raw).Trim().Split(',')
    $prog[1] = $Noun
    $prog[2] = $Verb

    :outer for ($i=0; $i -lt $prog.Count; $i+=4) {
        switch ($prog[$i]) {
            1 { $prog[$prog[$i+3]] = $prog[$prog[$i+1]] + $prog[$prog[$i+2]] }
            2 { $prog[$prog[$i+3]] = $prog[$prog[$i+1]] * $prog[$prog[$i+2]] }
            99 { break :outer }
        }
    }

    $prog[0]

}


# Part 1
if (-not $NoPart1) {

    RunProg $InputFile 12 2

}

# Part 2
if (-not $NoPart2) {

    # simple brute force
    :outer foreach ($n in (0..99)) {
        foreach ($v in (0..99)) {
            if ((RunProg $InputFile $n $v) -eq 19690720) {
                100 * $n + $v
                break :outer
            }
        }
    }

}
