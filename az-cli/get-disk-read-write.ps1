$diskIds = az disk list --query [].id | ConvertFrom-Json

$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

$disksOutput = @()

foreach($diskId in $diskIds){
    $diskName=$diskId.Split("/")[-1]
    $dsWrite = az monitor metrics list --resource $diskId `
    --metrics "Composite Disk Write Bytes/sec" `
    --aggregation maximum `
    --start-time $startDate `
    --end-time $endDate `
    --interval PT6H `
    --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumMax = 0
    foreach($value in $dsWrite.max){$sumMax+=$value/1mb}
    try {
        $mediaMaxWrite=($sumMax/$dsWrite.max.count).tostring("#.###")
    }
    catch {
        $mediaMaxWrite="0.00"
    }
    
    ############
    $dsRead = az monitor metrics list --resource $diskId `
        --metrics "Composite Disk Read Bytes/sec" `
        --aggregation maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumMax = 0
    foreach($value in $dsRead.max){$sumMax+=$value/1mb}
    try {
        $mediaMaxRead=($sumMax/$dsRead.max.count).tostring("#.###")
    }
    catch {
        $mediaMaxRead="0.00"
    }
    
    $disk = [PSCustomObject]@{
    diskName = "$diskName"
    mediaMaxWrite = $mediaMaxWrite
    mediaMaxRead = $mediaMaxRead
    }
    $disksOutput += $disk
    #Write-Output "$diskName $mediaMaxWrite $mediaMaxRead"
}

$disksOutput | Sort-Object -Property mediaMaxWrite -Descending
$disksOutput | Sort-Object -Property mediaMaxRead -Descending