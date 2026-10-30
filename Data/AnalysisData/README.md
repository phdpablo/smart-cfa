# Bases para análise

## Visão geral

Esta pasta contém a base final recodificada e sua partição em calibração e validação, utilizadas nas seções empíricas do artigo.

## Conteúdo

| Arquivo | Produção | Conteúdo atual |
| --- | --- | --- |
| `whoqol_analysis.csv` | [Seção 5](../../Article/05_preprocessing.qmd) | 1.243 participantes, `ID` e `Q1`–`Q26`; Q3, Q4 e Q26 recodificados por `6 - resposta` |
| `whoqol_cv.csv` | [Seção 6](../../Article/06_estimation.qmd) | Mesma base, com `missing_flag` e `sample_group` para calibração/validação |

A base final da seção 5 retém quem não falhou em nenhum dos cinco critérios de triagem. Os itens globais Q1 e Q2 permanecem no arquivo, mas os modelos de quatro domínios utilizam indicadores de Q3–Q26.

Na partição, `missing_flag = 0` indica ausência de valores omissos nos 24 indicadores; `1` indica pelo menos uma ausência. A divisão é estratificada por essa flag:

| `sample_group` | Parcela | Completos | Incompletos | Total |
| --- | --- | ---: | ---: | ---: |
| 0 | Calibração | 591 | 30 | 621 |
| 1 | Validação | 592 | 30 | 622 |

## Instruções de uso

Os CSVs usam ponto e vírgula e convenção decimal de `write_csv2()`. Leia `ID` como texto quando for necessário preservar sua representação.

A seção 6 reaproveita a partição salva e verifica sua correspondência com a base atual; ela não deve ser apagada para selecionar uma divisão favorável. As seções 6–7 utilizam calibração; a seção 8 utiliza validação e, na invariância multigrupo, as duas parcelas.

Ao substituir os dados, revise o protocolo e a partição antes de reexecutar as análises dependentes. A explicação executável da divisão está no callout próprio da seção 6. O [registro de exclusões](../../Output/DataAppendixOutput/README.md) documenta a triagem anterior.
