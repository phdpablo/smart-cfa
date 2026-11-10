# Metadados e síntese de literatura

## Visão geral

Esta pasta contém dois arquivos de entrada com funções diferentes. Ambos são CSVs separados por ponto e vírgula.

## Conteúdo

### Dicionário de variáveis

`codebook.csv` documenta as 108 colunas de [data.csv](../data.csv), com uma linha por variável. Os campos são:

| Campo | Conteúdo |
| --- | --- |
| `position_in_data` | Posição da coluna no arquivo bruto |
| `code_name` | Nome original da variável |
| `variable_label` | Descrição da variável |
| `measure_level` | Nível de mensuração registrado |
| `value_labels` | Códigos e rótulos de resposta, quando preenchidos |

O codebook descreve o dado de entrada. Novas variáveis de processamento, decisões de exclusão e grupos da validação são documentados nos QMDs e nas pastas de dados derivados. A origem da base está no [README de InputData](../README.md).

### Evidências para as modificações

`whoqol_modification_evidence.csv` é uma síntese de literatura revisada pelo autor e utilizada em [Article/08_model_comparison.qmd](../../../Article/08_model_comparison.qmd). Possui uma linha por item ou relação e três colunas de apresentação: prioridade de atenção, item/relação e síntese das evidências. As categorias Alta, Moderada e Pontual são qualitativas; a ordem dentro de uma categoria não é um ranking.

## Instruções de uso

O dicionário deve acompanhar os nomes e a ordem das colunas do arquivo bruto. Registre variáveis e decisões derivadas nas etapas de processamento correspondentes.

O arquivo de literatura não é calculado a partir dos índices de modificação da amostra. Fontes e notas de interpretação aparecem junto à tabela do artigo. Preserve essa distinção ao reutilizar o material e revise a síntese antes de alterar a tabela.
