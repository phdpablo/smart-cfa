# Tabelas exportadas

## Visão geral

Esta pasta contém os CSVs das tabelas e dos resíduos exportados pelas seções 5–8 do artigo.

## Conteúdo

| Arquivo | Conteúdo | Seção |
| --- | --- | --- |
| `tbl-hurdle-summary.csv` | Frequências de sinalização dos cinco critérios C/IER | 5 |
| `tbl-indicator-cutoffs.csv` | Limiares dos indicadores estatísticos da triagem | 5 |
| `tbl-analysis-sample-summary.csv` | Trajetória dos registros brutos até a amostra final | 5 |
| `tbl-item-description.csv` | Estatísticas descritivas dos itens | 5 |
| `tbl-estimation-parameters.csv` | Parâmetros dos modelos originais | 6 |
| `tbl-estimation-checks.csv` | Verificações da estimação | 6 |
| `tbl-model-fit-global.csv` | Ajuste global dos modelos originais | 7 |
| `tbl-domain-reliability.csv` | Confiabilidade dos escores nos modelos originais | 7 |
| `tbl-empirical-power-cutoffs.csv` | Limites e poder das simulações empíricas | 7 |
| `tbl-modification-indices-top20.csv` | Vinte maiores MI com EPC bruto e padronizado | 7 |
| `residual-correlations-h0.csv` | Diferenças de correlações observadas e implicadas em H0 | 7 |
| `tbl-adjusted-parameters.csv` | Parâmetros do modelo modificado na validação | 8 |
| `tbl-adjusted-model-fit-global.csv` | Ajuste global do modelo modificado | 8 |
| `tbl-adjusted-domain-reliability.csv` | Confiabilidade dos escores retidos | 8 |
| `tbl-adjusted-dfi-cutoffs.csv` | Referências Close/Fair/Mediocre do DDDFI | 8 |
| `tbl-adjusted-modification-indices-top20.csv` | MI/EPC do modelo modificado | 8 |
| `residual-correlations-adjusted.csv` | Diferenças de correlações no modelo modificado | 8 |
| `tbl-invariance-tests.csv` | Testes dos níveis e diferenças robustas de invariância | 8 |
| `tbl-invariance-fit-changes.csv` | Índices e mudanças entre níveis de invariância | 8 |
| `tbl-invariance-permutation.csv` | Diferenças observadas e valores-p da permutação métrica | 8 |

## Instruções de uso

Os arquivos são CSVs separados por ponto e vírgula. Os QMDs usam `write_csv2()` para tabelas numéricas e `write_excel_csv2()` para algumas tabelas de apresentação. Estas últimas podem conter números já formatados como texto com ponto decimal, mesmo quando o arquivo tem delimitador ponto e vírgula. Confira as colunas antes de importar para cálculo.

As seções 6–7 usam a calibração; o modelo modificado da seção 8 usa a validação e os testes multigrupo utilizam ambas. Leia os CSVs junto da interpretação no [artigo-fonte](../../../Article/README.md). As diferenças de correlações não são estimativas de covariâncias residuais livres do modelo.

Este inventário descreve as exportações atuais. Uma tabela mostrada no artigo pode não ter CSV próprio; não se pressupõe uma cópia exportada de cada saída.
