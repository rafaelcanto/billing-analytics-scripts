
# Replace with your tenantId
$tenantId = "1236ea7e-8bbc-43a5-a5ee-189a1954e314"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

# Time range
$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date

function Get-MsSqlCpuUsage {

    param ($resourceId)     

    $metricsResult = Get-AzMetric -ResourceId $resourceId -MetricName "cpu_percent" -StartTime $startDate -EndTime $endDate -TimeGrain "01:00:00" -AggregationType Maximum
    $result = $metricsResult.Data | Where-Object { $_.Maximum -gt 40 }
    if ($result.Count -gt 5) { return $true } else { return $false }
}

$lowusageDatabases = New-Object Collections.Generic.List[object]

$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId }

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $sqlServers = Get-AzSqlServer

    foreach ($sqlServer in $sqlServers) {
        
        $sqlDatabases = Get-AzSqlDatabase -ServerName $sqlServer.ServerName -ResourceGroupName $sqlServer.ResourceGroupName

        foreach ($database in $sqlDatabases) {
            
            $isCpuHighUsage = Get-MsSqlCpuUsage -resourceId $database.ResourceId;
    
            if ($isCpuHighUsage -eq $false) {
                Write-Host "Found! "$database.name
                $lowusageDatabases.Add($database)
            }
            
        }
    }
}

Write-Host "MSSQL Databases with low CPU usage: "
Write-Host "------------------------------"
$lowusageDatabases | Format-Table ServerName, DatabaseName, SkuName