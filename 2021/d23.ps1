#Requires -Version 7

[CmdletBinding()]
param(
    $InputFile = '.\d23.txt'
)

# https://adventofcode.com/2021/day/23

$state1 = @(
    ,@($null,$null,$null,$null,$null,$null,$null,$null,$null,$null,$null)
    ,@($null,$null)
    ,@($null,$null)
    ,@($null,$null)
    ,@($null,$null)
)
$lines = Get-Content $InputFile | ?{$_}
2..3 | %{
    $state1[1][$_-2] = [string]$lines[$_][3]
    $state1[2][$_-2] = [string]$lines[$_][5]
    $state1[3][$_-2] = [string]$lines[$_][7]
    $state1[4][$_-2] = [string]$lines[$_][9]
}

$state2 = @(
    ,@($null,$null,$null,$null,$null,$null,$null,$null,$null,$null,$null)
    ,@($null,'D','D',$null)
    ,@($null,'C','B',$null)
    ,@($null,'B','A',$null)
    ,@($null,'A','C',$null)
)
$lines = Get-Content $InputFile | ?{$_}
2..3 | %{
    $state1[1][$_-2] = [string]$lines[$_][3]
    $state1[2][$_-2] = [string]$lines[$_][5]
    $state1[3][$_-2] = [string]$lines[$_][7]
    $state1[4][$_-2] = [string]$lines[$_][9]
}
