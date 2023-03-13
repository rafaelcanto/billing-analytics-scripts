$sqlServers = az sql server list --query "[].{name:name,rg:resourceGroup}" | ConvertFrom-Json
$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

function Get-Databases {
    param ($server, $resourceGroup)

    $dbs = az sql db list --server $server --resource-group $resourceGroup | ConvertFrom-Json
    $objectToRemove = $dbs | Where-Object { $_.name -eq "master" }
    $dbs = $dbs | Where-Object { $_ -ne $objectToRemove }

    return $dbs
}

function Get-CPUDatabaseVcore {
    param ($database)

    $ds = az monitor metrics list --resource $database.id `
        --metrics "cpu_percent" `
        --aggregation Maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json

    $sumPercentageMax=0
    foreach($value in $ds.max){
        $sumPercentageMax += $value
    }
    try {
        $mediaMax=($sumPercentageMax/$ds.max.Count).tostring("#.##")
        return $mediaMax
    }
    catch {
        return 0
    }
}

function Get-CPUDatabaseDTU {
    param ($database)

    $ds = az monitor metrics list --resource $dbDTU `
        --metrics "dtu_consumption_percent" `
        --aggregation Maximum `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].maximum}' | ConvertFrom-Json
    
    $sumPercentageMax=0
    foreach($value in $ds.max){
        $sumPercentageMax += $value
    }
    try {
        $mediaMax=($sumPercentageMax/$ds.max.Count).tostring("#.###")
    }
    catch {
        return 0
    }
}

$sqlBadatabesOutput = @()

foreach ($server in $sqlServers) {
    $databases = Get-Databases -server $server.name -resourceGroup $server.rg
    
    switch ($databases){
        {$databases | Where-Object { $_.requestedServiceObjectiveName -like "S" }} {
            write-output "executnado para db DTU"
            $databases | Where-Object { $_.requestedServiceObjectiveName -like "S" } | select name

        }
        {$databases | Where-Object { $_.requestedServiceObjectiveName -like "GP_G*" }} {
            $mediaCPU = Get-CPUDatabaseVcore -database $_
            $mediaCPU
            $db = [PSCustomObject]@{
                "DB Name" = $_.name
                "Server Name" = $_.id.Split("/")[8] 
                "SKU" = "GeneralPurpose"
                "CPU %" = [System.Int32]$mediaCPU
                }
            $sqlBadatabesOutput += $db
        }
        {$databases | Where-Object { $_.requestedServiceObjectiveName -like "GP_S*" }} {
            $mediaCPU = Get-CPUDatabaseVcore -database $_
            $mediaCPU
            $db = [PSCustomObject]@{
                "DB Name" = $_.name
                "Server Name" = $_.id.Split("/")[8] 
                "SKU" = "GeneralPurpose Serverless"
                "CPU %" = [System.Int32]$mediaCPU
                }
            $sqlBadatabesOutput += $db
        }
        {$databases | Where-Object { $_.requestedServiceObjectiveName -like "Basic" }} {
            $mediaCPU = Get-CPUDatabaseDTU -database $_
            $mediaCPU
            $db = [PSCustomObject]@{
                "DB Name" = $_.name
                "Server Name" = $_.id.Split("/")[8] 
                "SKU" = "Basic"
                "CPU %" = [System.Int32]$mediaCPU
                }
            $sqlBadatabesOutput += $db
        }
    }
}

$sqlBadatabesOutput | Sort-Object -Property 'CPU %' -Descending