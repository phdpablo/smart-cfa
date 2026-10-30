# Modelos, helpers e persistência

## Visão geral

Apesar do nome herdado da estrutura do projeto, esta pasta reúne os scripts compartilhados do artigo, não apenas rotinas de apêndice.

## Conteúdo

| Arquivo | Papel |
| --- | --- |
| `models.R` | Define os modelos populacionais e os modelos livres originais/modificado utilizados pelos QMDs |
| `helpers.R` | Carrega pacotes, define parâmetros compartilhados e funções de extração, apresentação e gráficos |
| `cache_utils.R` | Define `cache_or_run()` para reaproveitar um objeto/RDS ou calcular e salvar um resultado |
| `cache_loader.R` | Define `cache_load_existing()`; só lê os RDS quando a função é chamada |
| `pre_render_cache.R` | Pre-render configurado em `_quarto.yml`; cria a pasta intermediária e regrava a definição do loader |

As especificações populacionais para planejamento devem ser distinguidas dos modelos ajustados aos dados empíricos. As seções carregam os arquivos de que precisam e mantêm explícitas suas chamadas de estimação e simulação.

Os parâmetros centrais atuais em `helpers.R` são `REP = 10`, `SIM = 1000`, `SEQ = rep(101:400, each = REP)`, `N_TARGET = 200` e `SEED = 123321`. Os helpers de apresentação recebem objetos já calculados; a documentação de propósito, entradas, saídas e exemplos está no próprio arquivo. Ela inclui diagramas coloridos/BW, tabelas dos resultados e gráfico DDDFI por referência, sem exigir um catálogo paralelo neste README.

## Instruções de uso

`cache_or_run()` procura o nome na sessão e depois o RDS. Dados, parâmetros ou modelos modificados não invalidam automaticamente esse resultado. A lista dos oito arquivos persistidos e sua origem está em [Data/IntermediateData/](../../Data/IntermediateData/README.md); o procedimento de recálculo está no [README principal](../../README.md#resultados-salvos-renderização-e-recálculo).

O pre-render não executa simulações nem instala pacotes. Mudanças manuais no loader gerado devem considerar que ele será regravado pelo pre-render. O antigo `render_cleanup.R` e sua chamada pós-render foram retirados da configuração atual.
