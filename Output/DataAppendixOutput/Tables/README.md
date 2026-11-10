# Registro de exclusões

## Visão geral

`exclusion_log.csv` é produzido na [seção 5](../../../Article/05_preprocessing.qmd), após a decisão conjunta de triagem. O arquivo atual contém 80 respondentes elegíveis que falharam em pelo menos um dos cinco critérios C/IER.

## Conteúdo

Além de ID, respostas e indicadores, o arquivo preserva as flags `fail_*`, `hurdles_failed`, `exclude` e `evidence`.

## Instruções de uso

Um participante pode falhar em vários critérios, por isso a soma das frequências por critério não equivale ao número de linhas deste arquivo.

Os 223 registros retirados antes dos obstáculos não estão nesse log. A trajetória completa está em [tbl-analysis-sample-summary.csv](../../Results/Tables/tbl-analysis-sample-summary.csv). O CSV usa ponto e vírgula e é uma saída derivada: regenere pelo QMD para alterar seu conteúdo.
