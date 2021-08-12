
# Cost Optimization Recipes

## Prioridades

- Baixo de uso
- Recursos abandonados
- Reservas

## Compute
- [x] VMs com pouca utilização (CPU < 40%). 

- VMs com SKU legado (D3S_V3, A_, etc)
Encontre VMs com SKU antigo:
https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-previous-gen

- [x] Reserve máquinas de produção

- Reserve discos de produção
- [x] Buscar discos maiores que P30 (1TB)

- [x] Escale os service plans com pouca utilização (CPU < 40%)

- Utilize licencas no formato BYOL - SEMPRE

## Storage
- Mova storage pouco acessado para Cool Storage (somente v2)
Analise as métricas ou billing (Data stored > RW Operations)

- Mova discos pouco utilizados para HDD ou STD SSD
*Encontrar discos com poucos IOPS (az monitor metric)

- [x] Apague discos orfãos



## Dev Policies
- Utilize série B* em dev/stg

- Utilize discos STD ou HDD em dev/stg

- Desligue máquinas virtuais fora do horário de desenvolvimento

- Desligue clusters do AKS de dev/stg fora do horário de desenvolvimento

- Pause instancias do Power BI Embedded fora do horário de desenvolvimento

- Desligue serviceplans para o F1 (free) fora do horário de desenvolvimento
* Buscar SKU premium em dev

- Implemente máquinas spot em ambientes de desenvolvimento

- Limite a retenção dos Log Analytics workspaces (free tier)


## Databases
- Aplique camada serveless em bancos com uso pontual

*IMPORTANTE*: Desabilite os crawlers das aplicacoes para evitar wake-ups constantes ou pare as aplicações

- Escale bancos de dados do SQL fora do horário crítico (automation)

- Escale bancos de dados (MySQL, SQL, PgSQL, MariaDB) com pouco uso (CPU < 40%)

- Mova bancos do SQL DTU > 200 para o modelo de vCore

- Reserve bancos de dados do SQL de produção (apenas vCore)

- Consolide cargas de trabalho com o SQL Elastic Pool

- Limite a retenção dos Log Analytics workspaces

- Ajuste o sampling rate das instancias do Application Insights

## Networking

- Encontre application gateways sem uso (avg total reqs < 100/h )

- Encontre firewalls sem uso (avg total reqs < 100/h )

- Encontre virtual network gateways sem uso (status das connections e point-to-site connections)