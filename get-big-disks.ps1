
# Big disks (>= 1TB) with usage should be reserved.


# Replace with your tenantId
$tenantId = "1236ea7e-8bbc-43a5-a5ee-189a1954e314"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

$bigDisks = New-Object Collections.Generic.List[object]

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $disks = Get-AzDisk | Where-Object { $_.DiskSizeGB -gt "1024" }
    $bigDisks += $disks
}

Write-Host "1TB+ disks (should be reserved)"
Write-Host "------------------------------"
$bigDisks | Format-Table