# Figuras exportadas

## Visão geral

Esta pasta contém as imagens PNG exportadas explicitamente pelas seções empíricas do artigo.

## Conteúdo

| Arquivo | Conteúdo | Fonte |
| --- | --- | --- |
| `fig-likert-social.png` | Distribuição das respostas nos itens do domínio social | Seção 5 |
| `fig-residual-correlations.png` | Heatmap das diferenças entre correlações observadas e implicadas em H0 | Seção 7 |
| `fig-residual-correlations-adjusted.png` | Mesmo diagnóstico no modelo modificado | Seção 8 |
| `fig-dfi-adjusted-fair.png` | Distribuições simuladas de CFI/RMSEA e limites da referência Fair | Seção 8 |

## Instruções de uso

Os arquivos são gravados por `ggsave()` nos QMDs de [Article/](../../../Article/README.md). Para mudar uma figura, ajuste sua chamada e regenere o arquivo. O gráfico DDDFI utiliza os índices salvos em `dfi_adjusted.rds`, sem precisar repetir a calibração apenas para redesenhá-lo.

Outras figuras — como diagramas CFA, curvas de poder e histogramas da permutação — são incorporadas diretamente ao documento. Os auxiliares gerados em `Article/*_files/` não são o inventário de figuras finais desta pasta.
