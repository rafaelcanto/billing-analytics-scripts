# Replace with your tenantId
$tenantId = "1236ea7e-8bbc-43a5-a5ee-189a1954e314"
Connect-AzAccount -TenantId $tenantId
$subscriptions = Get-AzSubscription | Where-Object { $_.TenantId -eq $tenantId } | Select-Object -First 5

$workspacesUsage = New-Object Collections.Generic.List[object]

foreach ($subscription in $subscriptions) {
    Write-Host "Getting recommendations for "$subscription.name
    Set-AzContext -Subscription $subscription.Id
    $workspaces = Get-AzOperationalInsightsWorkspace

    foreach ($workspace in $workspaces) {
        $usage = Get-AzOperationalInsightsWorkspaceUsage -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name
    }
    $workspacesUsage += $usage
}

$workspacesUsage | Format-Table