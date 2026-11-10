# Metadados dos dados de entrada

## Visão geral

Esta pasta contém o dicionário das variáveis dos dados de entrada, em CSV separado por ponto e vírgula.

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

## Instruções de uso

O dicionário deve acompanhar os nomes e a ordem das colunas do arquivo bruto. Registre variáveis e decisões derivadas nas etapas de processamento correspondentes.
