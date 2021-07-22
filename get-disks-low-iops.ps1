# Replace with your tenantId
$tenantId = "7c416a2f-a987-4337-bb0a-94e57c1f32e7"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }


# Date range
$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date

function Get-VMOSDiskIoUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "OS Disk IOPS Consumed Percentage" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}


function Get-VMDataDiskIoUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "Data Disk IOPS Consumed Percentage" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}


$lowUsageVMs = New-Object Collections.Generic.List[object]
$shoudBeReservedVMs = New-Object Collections.Generic.List[object]

$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq "7c416a2f-a987-4337-bb0a-94e57c1f32e7" }

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $virtualMachines = Get-AzVM

    foreach ($vm in $virtualMachines) {
        $isOsHighUsage = Get-VMOSDiskIoUsage -resourceId $vm.Id;
        $isDataHighUsage = Get-VMDataDiskIoUsage -resourceId $vm.Id;
        if ($isOsHighUsage -eq $false) {
            Write-Host "Found! "$vm.name
            $lowUsageVMs.Add($vm)
        }

        if ($isDataHighUsage -eq $true) {
            Write-Host "Found! "$vm.name
            $shoudBeReservedVMs.Add($vm)
        }
    }
}

$lowUsageVMs | Format-Table
$shoudBeReservedVMs | Format-Table
