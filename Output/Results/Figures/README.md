# Figuras exportadas

## Visão geral

Esta pasta contém as figuras exportadas das seções 2–8 do artigo: 15 PNGs e um SVG, correspondentes a 15 figuras numeradas (a permutação possui dois painéis).

## Conteúdo

| Arquivo | Conteúdo | Fonte |
| --- | --- | --- |
| `fig-cfa-decision-map.svg` | Mapa conceitual do percurso de AFC | Seção 2 |
| `fig-popmodel.png`, `fig-h1model.png` | Especificações dos modelos populacionais | Seção 3 |
| `fig-analytical-power.png` | Distribuições do qui-quadrado e poder analítico | Seção 4 |
| `fig-realistic-power.png`, `fig-realistic-curve.png` | Poder por tamanho amostral, com e sem suavização | Seção 4 |
| `fig-power-fixed.png`, `fig-power-fixed-traditional.png` | Distribuições dos índices no cenário de N fixo | Seção 4 |
| `fig-likert-social.png` | Distribuição das respostas nos itens do domínio social | Seção 5 |
| `fig-empirical-fit-distributions.png` | Distribuições empíricas dos índices de ajuste | Seção 7 |
| `fig-residual-correlations.png` | Heatmap das diferenças entre correlações observadas e implicadas em H0 | Seção 7 |
| `fig-adjusted-model.png` | Especificação do modelo modificado | Seção 8 |
| `fig-residual-correlations-adjusted.png` | Mesmo diagnóstico no modelo modificado | Seção 8 |
| `fig-dfi-adjusted-fair.png` | Distribuições simuladas de CFI/RMSEA e limites da referência Fair | Seção 8 |
| `fig-invariance-permutation-1.png`, `fig-invariance-permutation-2.png` | Histogramas da permutação métrica: CFI e RMSEA | Seção 8 |

## Instruções de uso

Os quatro PNGs de Likert, resíduos e DDDFI são gravados por `ggsave()` nos QMDs de [Article/](../../../Article/README.md). A rotina pós-renderização [export_figures.R](../../../Scripts/DataAppendixScripts/export_figures.R) exporta as demais imagens a partir do HTML e sincroniza os arquivos em `docs/Output/Results/Figures`. Os PNGs explícitos preservam sua resolução; os demais mantêm a resolução do recurso do Quarto. O mapa conceitual preserva o formato vetorial SVG.

Para atualizar uma figura, ajuste sua chamada e renderize a seção correspondente em HTML. A exportação também pode ser repetida com `Rscript Scripts/DataAppendixScripts/export_figures.R`, a partir da raiz, usando o HTML existente em `docs/Article`. Isso não recalcula análises nem simulações; a atualidade dos arquivos depende da renderização de origem. Uma renderização somente em PDF não atualiza o HTML usado pela rotina. O gráfico DDDFI utiliza os índices salvos em `dfi_adjusted.rds`, sem precisar repetir a calibração apenas para redesenhá-lo.

O exportador compara o conteúdo antes de copiar: arquivos novos ou diferentes são gravados, e arquivos idênticos mantêm conteúdo e data de modificação, tanto nesta pasta quanto em `docs/Output/Results/Figures`. A regra também vale para o SVG. Os quatro gráficos salvos por `ggsave()` continuam sob controle dos respectivos chunks; essa gravação é independente do pós-render.
