# Dettached disks should be deleted.

# Replace with your tenantId
$tenantId = "7c416a2f-a987-4337-bb0a-94e57c1f32e7"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

$orphanedDisks = New-Object Collections.Generic.List[object]
foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $disks = Get-AzDisk | Where-Object { $_.DiskState -eq "Unattached" }
    $orphanedDisks += $disks
}


Write-Host "Disks without attachment (should be deleted)"
Write-Host "------------------------------"
$orphanedDisks | Format-Table