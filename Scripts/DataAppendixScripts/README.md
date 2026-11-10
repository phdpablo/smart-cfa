# Modelos, helpers e persistência

## Visão geral

Esta pasta reúne os modelos, parâmetros e funções compartilhados pelas seções do artigo, além das rotinas de pré e pós-renderização.

## Conteúdo

| Arquivo | Papel |
| --- | --- |
| `models.R` | Define os modelos populacionais e os modelos livres originais/modificado utilizados pelos QMDs |
| `helpers.R` | Carrega pacotes, define parâmetros compartilhados e funções de extração, apresentação e gráficos |
| `cache_utils.R` | Define `cache_or_run()` para reaproveitar um objeto/RDS ou calcular e salvar um resultado |
| `cache_loader.R` | Define `cache_load_existing()`; só lê os RDS quando a função é chamada |
| `pre_render_cache.R` | Pre-render configurado em `_quarto.yml`; cria a pasta intermediária e regrava a definição do loader |
| `export_figures.R` | Pós-renderização: exporta figuras do HTML para `Output/Results/Figures` e sincroniza a cópia em `docs/Output`, sem executar análises |
| `format_docx.R` | Pós-renderização exclusiva do Word: separa tabelas de dados dos agrupamentos de figuras/legendas, aplica fonte de 10 pontos nas células e espaçamento externo de 18 pontos |

As especificações populacionais para planejamento devem ser distinguidas dos modelos ajustados aos dados empíricos. As seções carregam os arquivos de que precisam e mantêm explícitas suas chamadas de estimação e simulação.

Os parâmetros centrais atuais em `helpers.R` são `REP = 10`, `SIM = 1000`, `SEQ = rep(101:400, each = REP)`, `N_TARGET = 200` e `SEED = 123321`. Os helpers de apresentação recebem objetos já calculados; a documentação de propósito, entradas, saídas e exemplos está no próprio arquivo. Ela inclui diagramas coloridos/BW, tabelas dos resultados e gráfico 3DFI por referência, sem exigir um catálogo paralelo neste README.

## Instruções de uso

`cache_or_run()` procura o nome na sessão e depois o RDS. Dados, parâmetros ou modelos modificados não invalidam automaticamente esse resultado. A lista dos oito arquivos persistidos e sua origem está em [Data/IntermediateData/](../../Data/IntermediateData/README.md); o procedimento de recálculo está no [README principal](../../README.md#resultados-salvos-renderização-e-recálculo).

O pre-render não executa simulações nem instala pacotes. Mudanças manuais no loader gerado devem considerar que ele será regravado pelo pre-render. O pós-render `export_figures.R` utiliza `xml2` para exportar os recursos do HTML disponível, inclusive com resultados congelados. Preserva os PNGs exportados explicitamente pelos QMDs e não remove arquivos auxiliares. Compara o conteúdo antes de copiar: arquivos idênticos não são regravados, inclusive SVGs e cópias em `docs`. Para atualizar o conteúdo das figuras, renderize primeiro as respectivas seções em HTML.
