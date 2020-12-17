[CmdletBinding()]
param(
    [string]$InputFile = '.\d13.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    $data = Get-Content $InputFile
    [int]$depart = $data[0]


# Part 1
if (-not $NoPart1) {

    $nextBus = $data[1].Split(',') | ?{ $_ -ne 'x' } | %{
        [pscustomobject]@{
            id=$_
            ttn=[int]($_ - ($depart % $_))
        }
    } | sort ttn | select -first 1
    Write-Host "$($nextBus.ttn * $nextBus.id)"

}


# Part 2
if (-not $NoPart2) {

    # Modular Multiplicative Inverse
    # https://rosettacode.org/wiki/Modular_inverse
    # for a % m (where a and m are coprime),
    # find x where (a * x) % m = 1
    function Get-ModMultInv {
        param(
            [long]$a,
            [long]$m
        )

        if ($m -eq 1) { return 1 }

        $m0,$x0,$x1 = $m,0,1

        while ($a -gt 1) {
            [long]$q = [Math]::Floor($a/$m)
            $a,$m = $m,($a%$m)
            $x0,$x1 = ($x1 - $q * $x0),$x0
        }

        $x1 -lt 0 ? $x1 + $m0 : $x1
    }

    # Chinese Remainder Theorem (CRT)
    # https://rosettacode.org/wiki/Chinese_remainder_theorem
    function Get-ChineseRemainder {
        param(
            [int[]]$n,
            [int[]]$a
        )

        # multiply all of the $n values together
        [long]$prod = $n -join '*' | iex
        $sm = 0

        for ($i=0; $i -lt $n.Count; $i++) {
            #Write-Verbose "$prod / `$n[$i]`($($n[$i]))"
            $p = [Math]::Floor($prod / $n[$i])
            #Write-Verbose "`$p = $p($prod/$($n[$i]))  `$n[$i] = $($n[$i])"
            $modinv = Get-ModMultInv $p $n[$i]
            #Write-Verbose "modinv($p,$($n[$i])) = $modinv"
            #Write-Verbose "`$sm = $($sm+($a[$i] * $modinv * $p)) = $sm + ($($a[$i]) * $modinv * $p)"
            $sm += $a[$i] * $modinv * $p
        }
        #Write-Verbose "$($sm % $prod) = $sm % $prod"
        $sm % $prod
    }

    # build the n/a arrays of integers and remainders needed
    # for CRT
    $n=@(); $a=@()
    $data[1].Split(',') | % -Begin { $i=-1 } -Process {
        $i++
        if ($_ -ne 'x') {
            $n += [int]$_
            $a += ($i -eq 0) ? 0 : [int]$_ - ($i % $_)
        }
    }

    Get-ChineseRemainder $n $a


    Function Get-GCD ($x,$y) {
        while ($y -ne 0) {
            $x,$y = $y,($x % $y)
        }
        [Math]::Abs($x)
    }

    function Get-LCM ($a, $b) {
        [Math]::Abs($a*$b) / (Get-GCD $a $b)
    }

    $buses = $data[1] -split ',' | ForEach-Object { ($_ -ne 'x') ? [int]$_ : 0}
    Write-Verbose ($buses -join ',')
    $num = $step = $lastBus = $buses[0]
    for ($i=1; $i -lt $buses.Count; $i++) {
        $thisBus = $buses[$i]
        if ($thisBus -eq 0) { continue }

        Write-Verbose "num: $num bus: $thisBus step: $step"
        while( (($num+$i) % $thisBus) -ne 0) {
            Write-Verbose "$thisBus $($num+$i)"
            $num += $step
        }
        $step = Get-LCM $step ($thisBus*$lastBus)
        Write-Verbose "$thisBus $num $step"
        $lastBus = $thisBus
    }
    $num

}
