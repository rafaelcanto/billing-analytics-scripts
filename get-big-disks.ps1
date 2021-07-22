
# Big disks (>= 1TB) with usage should be reserved.


# Replace with your tenantId
$tenantId = "7c416a2f-a987-4337-bb0a-94e57c1f32e7"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

$bigDisks = New-Object Collections.Generic.List[object]

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $disks = Get-AzDisk | Where-Object { $_.DiskSizeGB -gt "1024" }
    $bigDisks += $disks
}

$bigDisks | Format-Table