
# Replace with your tenantId
$tenantId = "1236ea7e-8bbc-43a5-a5ee-189a1954e314"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

# Time range
$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date

function Get-PgServerCpuUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "cpu_percent" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}

$lowusageServers = New-Object Collections.Generic.List[object]

$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $pgServers = Get-AzPostgreSqlServer
    
    
    foreach ($server in $pgServers) {
        $isCpuHighUsage = Get-PgServerCpuUsage -resourceId $server.Id;

        if ($isCpuHighUsage -eq $false) {
            Write-Host "Found! "$server.name
            $lowusageServers.Add($server)
        }
    }
}

Write-Host "PgSQL Servers with low CPU usage (should be sized)"
Write-Host "------------------------------"
$lowusageServers | Format-Table