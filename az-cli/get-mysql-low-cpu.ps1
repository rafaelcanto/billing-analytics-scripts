$mySqlservers = az mysql server list | ConvertFrom-Json

$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

function Get-mySQLCpu {
    param ($resourceId)

    $dsMax = az monitor metrics list --resource $mysqlId.id `
        --metrics "cpu_percent" `
        --aggregation Maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumMax = 0
    foreach($value in $dsMax.max){$sumMax+=$value}
    $mediaMax=($sumMax/$ds.max.count).tostring("#.##")
    return $mediaMax
}

$mysqlOutput = @()

foreach ($mysqlId in $mySqlservers) {
    $mySqlName=$mysqlId.id.Split("/")[-1]

    $mediaCPU = Get-mySQLCpu -resourceId $mysqlId
    $sku = $mysqlId.sku.capacity
    $mysql = [PSCustomObject]@{
        "MySQL Server" = "$mySqlName"
        "cpuMax %" = [System.Int32]$mediaCPU
        Sku = "$sku vCore"
    }
    $mysqlOutput += $mysql
    write-Output "ASP: $mySqlName"
}

$mysqlOutput | Sort-Object -Property 'cpuMax %' -Descending
