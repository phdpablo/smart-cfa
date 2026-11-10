# Dados de entrada

## Visão geral

`data.csv` é o arquivo bruto utilizado na aplicação. O arquivo atual contém 1.546 registros e 108 colunas, incluindo identificação, timestamps, variáveis sociodemográficas, outros instrumentos do questionário, três itens de atenção (`CQ1`–`CQ3`) e os itens `Q1`–`Q26` da WHOQOL-Bref.

A fonte associada à base é Rogers, P., Barbosa, F., Peixoto, F., & Silva, D. R. (2024), *Data for “Asset diversification, financial well-being, quality of life, and mental health: a study in Brazil” published by Revista de Contabilidade & Finanças*, Mendeley Data, V2. [DOI: 10.17632/xvzsd8gk63.2](https://doi.org/10.17632/xvzsd8gk63.2). O número de casos do arquivo bruto deste projeto deve ser distinguido de bases já pré-processadas usadas em outros trabalhos.

## Conteúdo

| Conteúdo | Função |
| --- | --- |
| `data.csv` | Entrada empírica da seção 5, antes da elegibilidade, triagem e recodificação |
| `Metadata/codebook.csv` | Definições das 108 variáveis, na ordem do arquivo bruto |
| [whoqol_modification_evidence.csv](whoqol_modification_evidence.csv) | Síntese de literatura utilizada na fundamentação das modificações |

### Evidências para as modificações

[whoqol_modification_evidence.csv](whoqol_modification_evidence.csv) é uma síntese de literatura revisada pelo autor e utilizada em [Article/08_model_comparison.qmd](../../Article/08_model_comparison.qmd). Possui uma linha por item ou relação e três colunas de apresentação: prioridade de atenção, item/relação e síntese das evidências. As categorias Alta, Moderada e Pontual são qualitativas; a ordem dentro de uma categoria não é um ranking.

## Instruções de uso

O delimitador é ponto e vírgula. A [seção 5](../../Article/05_preprocessing.qmd) utiliza `read_csv2()`, calcula duração a partir de `CREATED` e `MODIFIED`, define elegibilidade e aplica os cinco critérios C/IER. As transformações são gravadas fora desta pasta; não edite o arquivo bruto para corrigir uma saída analítica.

Consulte [Metadata/](Metadata/README.md) para o esquema do codebook.

O arquivo de literatura não é calculado a partir dos índices de modificação da amostra. Fontes e notas de interpretação aparecem junto à tabela do artigo. Preserve essa distinção ao reutilizar o material e revise a síntese antes de alterar a tabela.
