
# All vms

$vmIds = az vm list --query "[].id" | ConvertFrom-Json
$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

$vmsMaxCPU = @()

function Get-vmCpuMax {
    param ($resourceId)     

    $ds = az monitor metrics list --resource $vmId `
        --metrics "Percentage CPU" `
        --aggregation maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT1H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumPercentage=0
    foreach ($value in $ds.max) {
        $sumPercentage+=$value
    }

    try {
        $mediaMax=0
        $mediaMax=($sumPercentage/$ds.max.Count).tostring("##.##")
        return $mediaMax

    }
    catch {
        return 0.00
    }
}

foreach ($vmId in $vmIds) {
    $vmName=$vmId.Split("/")[-1]
    $cpuMedia = Get-vmCpuMax
    
    $vm = [PSCustomObject]@{
        vmName = "$vmName"
        "cpuMax %" = [System.Int32]$cpuMedia
    }
    $vmsMaxCPU += $vm
    write-Output "VM: $vmName"
}
$vmsMaxCPU | Sort-Object -Property 'cpuMax %' -Descending
