Connect-AzAccount -TenantId "7c416a2f-a987-4337-bb0a-94e57c1f32e7"

$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date

function Get-VmCpuUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}


function Get-VmUsageTime {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $metricsResult = $metricsResult.Data | Where-Object { -not ([string]::IsNullOrEmpty($_.Maximum)) }
    if ($metricsResult.Count -gt 430) { return $true } else { return $false }
}

$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq "7c416a2f-a987-4337-bb0a-94e57c1f32e7" }

$lowUsageVMs = New-Object Collections.Generic.List[object]
$shoudBeReservedVMs = New-Object Collections.Generic.List[object]

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $virtualMachines = Get-AzVM

    foreach ($vm in $virtualMachines) {
        $isHighUsage = Get-VmCpuUsage -resourceId $vm.Id;
        $isReservationRecommended = Get-VmUsageTime -resourceId $vm.Id;
        if ($isHighUsage -eq $false) {
            Write-Host "Found! "$vm.name
            $lowUsageVMs.Add($vm)
        }

        if ($isReservationRecommended -eq $true) {
            Write-Host "Found! "$vm.name
            $shoudBeReservedVMs.Add($vm)
        }
    }
}


