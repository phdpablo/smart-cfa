# Dados de entrada

## Visão geral

`data.csv` é o arquivo bruto utilizado na aplicação. O arquivo atual contém 1.546 registros e 108 colunas, incluindo identificação, timestamps, variáveis sociodemográficas, outros instrumentos do questionário, três itens de atenção (`CQ1`–`CQ3`) e os itens `Q1`–`Q26` da WHOQOL-Bref.

A fonte associada à base é Rogers, P., Barbosa, F., Peixoto, F., & Silva, D. R. (2024), *Data for “Asset diversification, financial well-being, quality of life, and mental health: a study in Brazil” published by Revista de Contabilidade & Finanças*, Mendeley Data, V2. [DOI: 10.17632/xvzsd8gk63.2](https://doi.org/10.17632/xvzsd8gk63.2). O número de casos do arquivo bruto deste projeto deve ser distinguido de bases já pré-processadas usadas em outros trabalhos.

## Conteúdo

| Conteúdo | Função |
| --- | --- |
| `data.csv` | Entrada empírica da seção 5, antes da elegibilidade, triagem e recodificação |
| `Metadata/codebook.csv` | Definições das 108 variáveis, na ordem do arquivo bruto |
| `Metadata/whoqol_modification_evidence.csv` | Síntese de literatura utilizada na fundamentação das modificações |

## Instruções de uso

O delimitador é ponto e vírgula. A [seção 5](../../Article/05_preprocessing.qmd) utiliza `read_csv2()`, calcula duração a partir de `CREATED` e `MODIFIED`, define elegibilidade e aplica os cinco critérios C/IER. As transformações são gravadas fora desta pasta; não edite o arquivo bruto para corrigir uma saída analítica.

Consulte [Metadata/](Metadata/README.md) para o esquema do codebook e o papel do arquivo de literatura.
