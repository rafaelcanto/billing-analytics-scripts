$aspIds=az appservice plan list --query "[].id" | convertfrom-json
$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

$aspOutput = @()

function Get-aspCpu {
    param ($resourceId)

    $ds = az monitor metrics list --resource $aspId `
        --metrics "CpuPercentage" `
        --aggregation maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT1H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumPercentage=0
    foreach ($value in $ds.max) {
        $sumPercentage+=$value
    }
    try{
        $mediaMax=($sumPercentage/$ds.max.Count).tostring("#.##")
        return $mediaMax
    }
    catch {
        return 0.0
    }
}

foreach($aspId in $aspIds){
    $aspName=$aspId.Split("/")[-1]
    $mediaASP = Get-aspCpu -resourceId $aspId
    $asp = [PSCustomObject]@{
        aspName = "$aspName"
        "cpuMax %" = [System.Int32]$mediaASP
    }
    $aspOutput += $asp
    write-Output "ASP: $aspName"
}

$aspOutput | Sort-Object -Property 'cpuMax %' -Descending
