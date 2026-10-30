# Dados

## Visão geral

Esta pasta registra o percurso dos dados de entrada até as bases utilizadas na AFC. Os CSVs atuais usam ponto e vírgula; em R, leia-os com `readr::read_csv2()`.

## Conteúdo

| Pasta | Papel | Documentação |
| --- | --- | --- |
| `InputData/` | Dados de entrada e metadados preservados | [Conteúdo e origem](InputData/README.md) |
| `IntermediateData/` | Etapas da triagem e resultados persistidos de simulações/permutação | [Inventário e recálculo](IntermediateData/README.md) |
| `AnalysisData/` | Base recodificada e partição de calibração/validação | [Bases analíticas](AnalysisData/README.md) |

A [seção 5](../Article/05_preprocessing.qmd) lê `InputData/data.csv`, registra elegibilidade e triagem em `IntermediateData/` e grava `AnalysisData/whoqol_analysis.csv`. A [seção 6](../Article/06_estimation.qmd) recupera ou cria a partição em `AnalysisData/whoqol_cv.csv`. As seções seguintes usam explicitamente as parcelas de calibração e validação.

Os resultados de apresentação são exportados em [Output/](../Output/README.md). Os RDS permanecem aqui porque alimentam as análises e evitam repetir cálculos demorados. Eles não são um substituto das bases de dados nem das fontes QMD.

## Instruções de uso

Preserve os dados de entrada. Uma adaptação de dados, itens ou modelos exige revisar os produtos intermediários, a partição e os resultados persistidos correspondentes; o mecanismo de cache não detecta essas alterações automaticamente. Veja o [procedimento de recálculo](../README.md#resultados-salvos-renderização-e-recálculo).
