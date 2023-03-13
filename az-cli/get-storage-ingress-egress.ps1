$stIds=az storage account list --query "[].id" | ConvertFrom-Json

$endDate = get-date -format "yyyy-MM-ddT00:00:00Z"
$startDate = get-date (get-date).AddDays(-30) -Format "yyyy-MM-ddT00:00:00Z"

$storageOutput = @()

function Get-StorageIngress {
    param ($resourceId)     

    $ds = az monitor metrics list --resource $stId `
        --metrics "Ingress" `
        --aggregation total `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].total}' | ConvertFrom-Json

    $sumIngressMax=0
    foreach($value in $ds.max){
        $sumIngressMax += $value
    }
    $mediaIngress=($sumIngressMax/1mb).toString("#.##")

    return $mediaIngress
}

function Get-StorageEgress {
    param ($resourceId)     

    $ds = az monitor metrics list --resource $stId `
        --metrics "Egress" `
        --aggregation total `
        --start-time $startDate `
        --end-time $endDate `
        --interval PT6H `
        --query '{max:value[].timeseries[].data[].total}' | ConvertFrom-Json

    $sumEgressMax=0
    foreach($value in $ds.max){
        $sumEgressMax += $value
    }
    $mediaEgress=($sumEgressMax/1mb).toString("#.##")

    return $mediaEgress
}


foreach ($stId in $stIds) {
    $stName=$stId.Split("/")[-1]
    $mediaIngress = Get-StorageIngress -resourceId $stId
    $mediaEgress = get-StorageEgress -resourceId $stId

    $st = [PSCustomObject]@{
        stName = "$stName"
        "Ingress/mb" = [System.Int32]$mediaIngress
        "Egress/mb" = [System.Int32]$mediaEgress
        }
    $storageOutput += $st
    write-Output "storage: $stName"
}

$storageOutput | Sort-Object -Property 'Ingress/mb' -Descending
$storageOutput | Sort-Object -Property 'Egress/mb' -Descending