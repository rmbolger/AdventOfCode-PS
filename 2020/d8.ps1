[CmdletBinding()]
param(
    [string]$InputFile = '.\d8.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

# convert the input into a simple set of custom objects
$commands = Get-Content $InputFile | ForEach-Object {
    [pscustomobject]@{
        cmd = $_.Substring(0,3)
        num = $_.Substring(4) -as [int]
    }
}

    # a function to "run the program" and return the acc value
    # when it terminates or put it in the error if there's an error
    function Invoke-Day8App {
        [CmdletBinding()]
        param(
            [pscustomobject[]]$Cmds,
            [int]$SwapOpIndex=-1
        )

        # create a hashset to store the cmd indexes we've already run
        $cmdsRun = [System.Collections.Generic.HashSet[int]]::new()

        # initialize the cmd index and accumulator
        [int]$i = [int]$acc = 0

        try {

            while ($i -ge 0 -and $i -le ($Cmds.Count-1)) {

                # check for infinite loop
                if (-not $cmdsRun.Add($i)) {
                    Write-Verbose "INFINITE LOOP"
                    throw "Repeated command at index $i. Accumulator $acc"
                }

                # swap the cmd if we're at the specified change index
                $cmd = if ($i -eq $SwapOpIndex) {
                    ($Cmds[$i].cmd -eq 'jmp') ? 'nop' : 'jmp'
                } else {
                    $Cmds[$i].cmd
                }
                $num = $Cmds[$i].num

                # do the operation
                $msgVerbose = "$($i.ToString('000')) $cmd $num".PadRight(13)
                switch ($cmd) {
                    'acc' { $i++; $acc += $num }
                    'jmp' { $i += $num }
                    'nop' { $i++ }
                }
                Write-Verbose "$msgVerbose - acc($acc)"
            }

            if ($i -lt 0) {
                Write-Verbose "BAD JUMP"
                throw "Jumped before beginning of program at index $i. Accumulator $acc"
            }

            return $acc
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

# Part 1
if (-not $NoPart1) {

    Write-Host "Part 1"
    Invoke-Day8App $commands -EA Continue

}

# Part 2
if (-not $NoPart2) {

    # create a list of possible change indexes
    $iChanges = 0..($commands.Count-1) |
        Where-Object { $commands[$_].cmd -ne 'acc' }

    # loop through them looking for a successful run
    foreach ($ic in $iChanges) {
        try {
            if ($result = Invoke-Day8App $commands $ic) {
                Write-Host "Part 2 Accumulator $result"
                break
            }
        } catch {}
    }

}
