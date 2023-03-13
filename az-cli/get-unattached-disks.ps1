

az disk list --query "[?diskState=='Unattached'].{Name:name, RG:resourceGroup, Location:location, DiskSizeGb:diskSizeGb, SKU:sku.tier}" `
--output table
