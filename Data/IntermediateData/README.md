# Dados intermediários e resultados persistidos

## Visão geral

Esta pasta reúne os CSVs da triagem e os oito RDS utilizados nas etapas computacionais mais demoradas. Os arquivos atuais são versionados junto ao projeto. Não é necessário repetir as simulações para examinar o artigo com os resultados distribuídos.

## Conteúdo

### Etapas da triagem

| Arquivo | Conteúdo | Fonte |
| --- | --- | --- |
| `whoqol_eligible.csv` | Registros após a exclusão preliminar por identificação/ausências | Seção 5, `data-preparation` |
| `whoqol_procedural.csv` | Itens, duração, controles de atenção e flags procedurais | Seção 5 |
| `whoqol_indicators.csv` | Longstring, IRV, Mahalanobis e suas flags, por ID | Seção 5 |
| `whoqol_preprocessed.csv` | Indicadores reunidos, critérios falhados, decisão `exclude` e `evidence` | Seção 5 |

Esses arquivos antecedem a recodificação dos itens negativos na base final. A [seção 5](../../Article/05_preprocessing.qmd) contém os critérios e a ordem de aplicação; a base final está em `Data/AnalysisData/`.

### Inventário dos RDS

| Arquivo | Objeto utilizado no QMD | Fonte e configuração solicitada |
| --- | --- | --- |
| `popmodel_101to400.rds` | `popmodel_varying` | Seção 4, referência; N de 101 a 400, dez replicações por N |
| `h1model_101to400.rds` | `h1model_varying` | Seção 4, alternativa com cargas cruzadas; mesma sequência de N |
| `popmodel_200.rds` | `popmodel_fixed` | Seção 4, referência; N = 200, 1.000 replicações |
| `h1model_200.rds` | `h1model_fixed` | Seção 4, alternativa; N = 200, 1.000 replicações |
| `sim_h0_empirical.rds` | `sim_h0_empirical` | Seção 7, condição empírica H0 na calibração, 1.000 replicações |
| `sim_h1_empirical.rds` | `sim_h1_empirical` | Seção 7, condição empírica H1 na calibração, 1.000 replicações |
| `dfi_adjusted.rds` | `dfi_adjusted` | Seção 8, DDDFI do modelo modificado na validação, 1.000 replicações |
| `perm_metric.rds` | `perm_metric` | Seção 8, permutação métrica/configural estratificada, 1.000 permutações |

As configurações acima descrevem as chamadas atuais. A correspondência interna de cada arquivo com a configuração geradora é uma verificação necessária em uma auditoria de reprodução; apenas encontrar o arquivo não comprova essa correspondência. `dfi_adjusted.rds` preserva índices e pontos de corte e dispensa o componente volumoso `simulated_data`.

## Instruções de uso

`cache_or_run()` busca primeiro um objeto pelo nome de cache na sessão e depois o arquivo RDS; calcula e salva somente quando ambos faltam. Na seção 4, por exemplo, o nome de cache `popmodel_200` difere do objeto de apresentação `popmodel_fixed`. Reinicie a sessão ao preparar um recálculo para evitar reutilização inadvertida.

Carregar a definição de `cache_loader.R` não lê arquivos. A chamada explícita `cache_load_existing()` lê todos os RDS disponíveis, atribuindo nomes a partir dos arquivos. Ela não verifica se dados, modelos ou parâmetros mudaram.

Para refazer uma etapa, preserve os RDS antigos fora desta pasta, retire apenas os resultados envolvidos e execute a seção pertinente em sessão limpa. Um recálculo com dados/modelos diferentes pode exigir também refazer os produtos das seções seguintes. Não elimine toda a pasta para atualizar uma figura: isso pode iniciar várias simulações e a permutação de 28 processos. Consulte o [README principal](../../README.md#resultados-salvos-renderização-e-recálculo).
