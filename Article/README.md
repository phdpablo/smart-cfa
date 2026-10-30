# Fontes do artigo

## Visão geral

Esta pasta contém o texto e os chunks executáveis do artigo em português. A configuração de formatos, bibliografia e ordem das seções está em [../_quarto.yml](../_quarto.yml).

## Conteúdo

| Arquivo | Conteúdo |
| --- | --- |
| `00_abstract.qmd` | Texto do resumo e palavras-chave, incluído pelo `index.qmd` da raiz |
| `01_intro.qmd` | Objetivos, público e organização do tutorial |
| `02_background.qmd` | Fundamentação metodológica e mapa do percurso |
| `03_model_selection.qmd` | Modelos planejados, diagramas e preparação computacional geral |
| `04_pa.qmd` | Poder analítico e simulações com N variável e fixo |
| `05_preprocessing.qmd` | Elegibilidade, cinco critérios C/IER, recodificação e descrição dos itens |
| `06_estimation.qmd` | Partição persistida e estimação dos modelos originais na calibração |
| `07_model_fit.qmd` | Ajuste, confiabilidade, simulações empíricas e diagnóstico na calibração |
| `08_model_comparison.qmd` | Modificações fundamentadas, validação, 3DFI, diagnóstico e invariância |
| `09_conclusion.qmd` | Conclusão |
| `references.qmd` | Local de inserção da bibliografia processada pelo Quarto |
| `references.bib` | Referências bibliográficas em BibTeX |
| `apa7ed.csl` | Estilo de citações e referências APA 7 |

## Instruções de uso

O [index.qmd](../index.qmd) da raiz define o título `Resumo`, a classe `.unnumbered` e a âncora `sec-abstract`. O corpo é incluído a partir de `00_abstract.qmd`; não adicione esse arquivo como capítulo separado. As demais seções fornecem o próprio título em seu primeiro cabeçalho.

Os caminhos R usam a raiz do projeto; links Markdown para scripts e dados fora desta pasta usam `../`. Os callouts são a camada didática do HTML e, quando marcados com `unless-format="pdf"`, ficam ausentes do PDF. Chunks executáveis recolhíveis produzem resultados; exemplos com `eval: false` apenas mostram o código.

Renderize a partir da raiz. A saída HTML das seções fica em `docs/Article/`; o PDF do livro é único. Pastas como `02_background_files/` são recursos intermediários gerados pelo Quarto/Graphviz e estão ignoradas pelo Git. Os PNGs exportados deliberadamente pelo artigo ficam em `Output/Results/Figures/`.

Consulte o [README principal](../README.md) antes de renderizar ou recalcular simulações: renderizar um QMD isolado executa seus chunks e ainda pode reutilizar os RDS existentes.
