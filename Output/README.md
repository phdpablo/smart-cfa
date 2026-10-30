# Resultados exportados

## Visão geral

Esta pasta contém arquivos gravados explicitamente pelos QMDs: tabelas, figuras e o registro de exclusões da triagem. Ela é distinta de `docs/`, que recebe o artigo renderizado e seus recursos web/PDF.

## Conteúdo

| Pasta | Conteúdo |
| --- | --- |
| [Results/](Results/README.md) | Tabelas e figuras analíticas do artigo, organizadas em `Tables/` e `Figures/` |
| [DataAppendixOutput/](DataAppendixOutput/README.md) | Registro das exclusões por C/IER, em `Tables/exclusion_log.csv` |

## Instruções de uso

Os arquivos são derivados. Para mudar um resultado, altere o procedimento e regenere a saída no QMD de origem; não edite células ou imagens para corrigir a apresentação final. Alguns gráficos e tabelas existem apenas no documento renderizado, sem exportação separada nesta pasta.

Os resultados persistidos de simulação/permutação ficam em [Data/IntermediateData/](../Data/IntermediateData/README.md), não em Output. Ao renderizar com esses RDS, os QMDs podem atualizar os CSVs e PNGs de apresentação sem recalcular as simulações.
