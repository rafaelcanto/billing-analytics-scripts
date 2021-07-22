$orphanedDisks = New-Object Collections.Generic.List[object]


$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq "7c416a2f-a987-4337-bb0a-94e57c1f32e7" }

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $disks = Get-AzDisk | Where-Object { $_.DiskState -eq "Unattached" }
    $orphanedDisks += $disks
}

$orphanedDisks | Format-Table Id