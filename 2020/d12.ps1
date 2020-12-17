[CmdletBinding()]
param(
    [string]$InputFile = '.\d12.txt',
    [switch]$NoPart1,
    [switch]$NoPart2
)

    $route = Get-Content $InputFile | %{
        [pscustomobject]@{a=$_.Substring(0,1);v=[int]$_.Substring(1)}
    }

# Part 1
if (-not $NoPart1) {

    $rNext = @{E='S';S='W';W='N';N='E'}
    $lNext = @{E='N';N='W';W='S';S='E'}
    $opposites = @{E='W';W='E';N='S';S='N'}

    $fwdAction = 'E'
    $loc = @{x=0;y=0}
    foreach ($cmd in $route) {
        # change the forward action to whatever direction we're facing
        $a = $cmd.a
        if ($a -eq 'F') { $a = $fwdAction }

        # move for compass directions
        if ($a -eq 'N') { $loc.y += $cmd.v }
        elseif ($a -eq 'S'){ $loc.y -= $cmd.v }
        elseif ($a -eq 'E'){ $loc.x += $cmd.v }
        elseif ($a -eq 'W'){ $loc.x -= $cmd.v }

        # change directions
        elseif (($a -eq 'R' -and $cmd.v -eq 90) -or
            ($a -eq 'L' -and $cmd.v -eq 270))
        {
            #Write-Verbose "$($a)$($cmd.v): $fwdAction -> $($rNext[$fwdAction])"
            $fwdAction = $rNext[$fwdAction]
        }
        elseif (($a -eq 'L' -and $cmd.v -eq 90) -or
                ($a -eq 'R' -and $cmd.v -eq 270))
        {
            #Write-Verbose "$($a)$($cmd.v): $fwdAction -> $($lNext[$fwdAction])"
            $fwdAction = $lNext[$fwdAction]
        }
        elseif ($a -in 'R','L' -and $cmd.v -eq 180) {
            #Write-Verbose "$($a)$($cmd.v): $fwdAction -> $($opposites[$fwdAction])"
            $fwdAction = $opposites[$fwdAction]
        }
        #Write-Verbose "$($loc.x),$($loc.y)"
    }
    [Math]::Abs($loc.x) + [Math]::Abs($loc.y)

}


# Part 2
if (-not $NoPart2) {

    $ship = @{x=0;y=0}
    $wp = @{x=10;y=1}
    foreach ($cmd in $route) {

        # move ship
        if ($cmd.a -eq 'F') {
            $ship.x += $cmd.v * $wp.x
            $ship.y += $cmd.v * $wp.y
        }
        # move waypoint
        elseif ($cmd.a -eq 'N') { $wp.y += $cmd.v }
        elseif ($cmd.a -eq 'S') { $wp.y -= $cmd.v }
        elseif ($cmd.a -eq 'E') { $wp.x += $cmd.v }
        elseif ($cmd.a -eq 'W') { $wp.x -= $cmd.v }

        # rotate waypoint
        elseif (($cmd.a -eq 'R' -and $cmd.v -eq 90) -or
                ($cmd.a -eq 'L' -and $cmd.v -eq 270))
        {
            # x = y  y = -x
            $wp.x,$wp.y = $wp.y,($wp.x*-1)
        }
        elseif (($cmd.a -eq 'L' -and $cmd.v -eq 90) -or
                ($cmd.a -eq 'R' -and $cmd.v -eq 270))
        {
            # x = -y   y = x
            $wp.x,$wp.y = ($wp.y*-1),$wp.x
        }
        elseif ($cmd.a -in 'R','L' -and $cmd.v -eq 180) {
            # negate both wp axes
            $wp.x *= -1
            $wp.y *= -1
        }
        #Write-Verbose "$(($cmd.a + $cmd.v).PadRight(5)): ship($($ship.x),$($ship.y)) wp($($wp.x),$($wp.y))"
    }
    [Math]::Abs($ship.x) + [Math]::Abs($ship.y)



}
