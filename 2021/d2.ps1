#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d2.txt'
)

# https://adventofcode.com/2021/day/2

$cmds = Get-Content $InputFile
Set-Clipboard $cmds

# Part 1's "depth" is just Part 2's "aim" so easy to combine both into a single loop

$pos=$dep=$aim=0
Get-Clipboard | ForEach-Object {
    $cmd,$val = -split $_   # default whitespace delimiter
    switch -Regex ($cmd) {
        f {
            $pos += $val
            $dep += $aim * $val
        }
        u {
            $aim -= $val
        }
        n {                 # 'n' is the only char in 'down' that has no matches in other commands
            $aim += $val
        }
    }
}
$pos * $aim
$pos * $dep

# Partially Minimized
$p=$d=$a=0
gcb|%{
    $c,$v=-split$_
    switch -r($c) {
        f{$p+=$v;$d+=$a*$v}
        u{$a-=$v}
        n{$a+=$v}
    }
}
$p*$a
$p*$d


# Golfed - 97 chars
$p=$d=$a=0;gcb|%{$c,$v=-split$_;switch -r($c){f{$p+=$v;$d+=$a*$v}u{$a-=$v}n{$a+=$v}}};$p*$a;$p*$d


# Abusing iex and script variables
$script:pos = $script:dep = $script:aim = 0
function forward ($val) {
    $script:pos += $val
    $script:dep += $script:aim * $val
}
function up ($val) {
    $script:aim -= $val
}
function down ($val) {
    $script:aim += $val
}
Get-Clipboard | ForEach-Object { iex $_ }
$pos*$aim
$pos*$dep


# Using script methods on a custom object
$sub = [pscustomobject]@{
    pos = 0
    dep = 0
    aim = 0
}
$sub | Add-Member ScriptMethod forward {
    $v=$args[0]
    $this.pos += $v
    $this.dep += $this.aim * $v
}
$sub | Add-Member ScriptMethod up {
    $this.aim -= $args[0]
}
$sub | Add-Member ScriptMethod down {
    $this.aim += $args[0]
}
Get-Clipboard | ForEach-Object {
    $cmd,$val = -split $_
    $sub.$cmd($val)
}
$sub.pos*$sub.aim
$sub.pos*$sub.dep
