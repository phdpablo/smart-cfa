# Scripts compartilhados

## Visão geral

A execução do artigo é organizada pelos QMDs de [Article/](../Article/README.md), na ordem definida em `_quarto.yml`. Os scripts desta pasta fornecem especificações, parâmetros, funções de apresentação e persistência.

## Conteúdo

| Pasta | Situação atual |
| --- | --- |
| [DataAppendixScripts/](DataAppendixScripts/README.md) | Contém os cinco scripts R ativos, reutilizados pelas seções |
| [ProcessingScripts/](ProcessingScripts/README.md) | Contém apenas README; o pré-processamento está na seção 5 |
| [AnalysisScripts/](AnalysisScripts/README.md) | Contém apenas README; as análises estão nas seções 4 e 6–8 |

Não há um script mestre R separado: o Quarto coordena a execução dos documentos. Cada seção carrega seus scripts e insumos próprios; uma sessão interativa com objetos de outra seção não deve ser requisito da reprodução.

## Instruções de uso

Os caminhos são relativos à raiz, com `here::here()` e `execute-dir: project`. A descrição dos argumentos dos helpers permanece no código; estas páginas documentam os papéis dos arquivos. Para instalar dependências e executar, use o [README principal](../README.md).
