$enemies = @{
    'LadyBug' = [pscustomobject]@{respawn = 5; points = 1; bond = 300}
    'RhinoBeetle' = [pscustomobject]@{respawn = 5; points = 1; bond = 300}
    'Mantis' = [pscustomobject]@{respawn = 17; points = 5; bond = 1550}
    'Scorpion' = [pscustomobject]@{respawn = 17; points = 5; bond = 1550}
    'Spider' = [pscustomobject]@{respawn = 26; points = 10; bond = 3100}
    'Werewolf' = [pscustomobject]@{respawn = 51; points = 25; bond = 6150}
    'KingBeetle' = [pscustomobject]@{respawn = ([TimeSpan]'21:00:00').TotalMinutes; points = 150; bond = 30750}
    'TunnelBear' = [pscustomobject]@{respawn = ([TimeSpan]'1.16:00:00').TotalMinutes; points = 200; bond = 61500}
}

$fields = @(
    [pscustomobject]@{ field='Mushroom'; enemies=@($enemies.'LadyBug') }
    [pscustomobject]@{ field='BlueFlower'; enemies=@($enemies.'RhinoBeetle') }
    [pscustomobject]@{ field='Clover'; enemies=@($enemies.'RhinoBeetle') + @($enemies.'LadyBug') }
    [pscustomobject]@{ field='Strawberry'; enemies=@($enemies.'LadyBug')*2 }
    [pscustomobject]@{ field='Spider'; enemies=@($enemies.'Spider') }
    [pscustomobject]@{ field='Bamboo'; enemies=@($enemies.'RhinoBeetle')*2 }
    [pscustomobject]@{ field='Rose'; enemies=@($enemies.'Scorpion')*2 }
    [pscustomobject]@{ field='Pineapple'; enemies=@($enemies.'Mantis') + @($enemies.'RhinoBeetle') }
    [pscustomobject]@{ field='Pinetree'; enemies=@($enemies.'Mantis')*2 + @($enemies.'Werewolf') }
    [pscustomobject]@{ field='KingBeetle'; enemies=@($enemies.'KingBeetle') }
    [pscustomobject]@{ field='TunnelBear'; enemies=@($enemies.'TunnelBear') }
)

foreach ($f in $fields) {

    # find the common denominator of unique respawns where the respawn times
    # of everything in the field converge
    $uniqueRespawns = $f.enemies.respawn | sort -unique
    $commonRespawn = 1
    $uniqueRespawns | %{ $commonRespawn *= $_ }

    # sum each enemy's data after normalizing for the common respawn
    $f.enemies | ForEach-Object -Begin {
        $totalPoints = 0
        $totalBond = 0
    } -Process {
        $multiple = $commonRespawn / $_.respawn
        $totalPoints += $_.points * $multiple
        $totalBond += $_.bond * $multiple
    }

    [pscustomobject]@{
        field = $f.field
        PtsPerHour = [Math]::Round($totalPoints / ($commonRespawn / 60))
        PtsPerDay = [Math]::Round($totalPoints / ($commonRespawn / 1440))
        BondPerHour = [Math]::Round($totalBond / ($commonRespawn / 60))
        BondPerDay = [Math]::Round($totalBond / ($commonRespawn / 1440))
    }
}
