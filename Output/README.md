# Resultados exportados

## Visão geral

Esta pasta contém tabelas e o registro de exclusões gravados pelos QMDs, além de figuras exportadas pelos QMDs ou pela rotina pós-renderização. Ela é distinta de `docs/`, que recebe o artigo renderizado e seus recursos web/PDF.

## Conteúdo

| Pasta | Conteúdo |
| --- | --- |
| [Results/](Results/README.md) | Tabelas e figuras analíticas do artigo, organizadas em `Tables/` e `Figures/` |
| [DataAppendixOutput/](DataAppendixOutput/README.md) | Registro das exclusões por C/IER, em `Tables/exclusion_log.csv` |

## Instruções de uso

Os arquivos são derivados. Para mudar um resultado, altere o procedimento e regenere a saída no QMD de origem; não edite células ou imagens para corrigir a apresentação final. As 15 figuras numeradas são exportadas em 16 arquivos. Duas tabelas não têm CSV próprio nesta pasta: os pressupostos definidos no código e a síntese bibliográfica, cujo CSV-fonte está em `Data/InputData/whoqol_modification_evidence.csv`.

Os resultados persistidos de simulação/permutação ficam em [Data/IntermediateData/](../Data/IntermediateData/README.md), não em Output. Ao renderizar com esses RDS, os QMDs podem atualizar os CSVs e PNGs de apresentação sem recalcular as simulações.
