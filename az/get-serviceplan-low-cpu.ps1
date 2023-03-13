# Service Plans with low CPU usage should be resized.

# Replace with your tenantId
$tenantId = "a680bede-9e00-4d2c-a1f0-8df2bea6b6f6"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

# Time range
$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date

function Get-ServicePlanUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "CPUPercentage" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}

$lowUsageServicePlans = New-Object Collections.Generic.List[object]

$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq "a680bede-9e00-4d2c-a1f0-8df2bea6b6f6" }

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $servicePlans = Get-AzAppServicePlan
    
    
    foreach ($servicePlan in $servicePlans) {
        $isCpuHighUsage = Get-ServicePlanUsage -resourceId $servicePlan.Id;

        if ($isCpuHighUsage -eq $false) {
            Write-Host "Found! "$servicePlan.name
            $lowUsageServicePlans.Add($servicePlan)
        }
    }
}

Write-Host "Low CPU usage Service Plans (should be resized)"
Write-Host "------------------------------"
$lowUsageServicePlans | Format-Table