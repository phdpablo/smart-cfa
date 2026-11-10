# Planejamento e avaliação de modelos de análise fatorial confirmatória

*Um tutorial reprodutível com R e Quarto*

![Preprint em preparação](https://img.shields.io/badge/Preprint-em%20prepara%C3%A7%C3%A3o-lightgrey) [![Protocolo TIER 4.0](https://img.shields.io/badge/Protocolo%20TIER-4.0-green)](https://www.projecttier.org/tier-protocol/protocol-4-0/) [![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Artigo-blue)](https://phdpablo.github.io/cfa-tutorial/) [![Licença](https://img.shields.io/badge/Licen%C3%A7a-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/) [![R](https://img.shields.io/badge/R-4.5.2-orange)](https://www.r-project.org/) [![Quarto](https://img.shields.io/badge/Quarto-1.9.37-orange)](https://quarto.org/) [![Docker](https://img.shields.io/badge/Docker-Compose-orange)](docker/README.md) [![renv](https://img.shields.io/badge/renv-1.2.4-orange)](https://rstudio.github.io/renv/)

Pablo Rogers e Sérgio Murilo Georgeto

> Rogers, P., & Georgeto, S. M. [Ano a definir]. *Planejamento e avaliação de modelos de análise fatorial confirmatória: um tutorial reprodutível com R e Quarto*. [Preprint; repositório e DOI a definir].

Este repositório reúne o artigo-tutorial, os dados e os procedimentos computacionais de uma aplicação de análise fatorial confirmatória (AFC) à WHOQOL-Bref. O percurso articula seleção do modelo, análise de poder, triagem de respostas, estimação MLR/FIML, avaliação global e local, modificações fundamentadas e avaliação da estabilidade entre amostras de calibração e validação por invariância de medida.

O HTML apresenta a narrativa acompanhada de callouts com explicações e código. O PDF preserva a leitura contínua do artigo. A organização dos materiais utiliza o [ARTE 2.0](https://github.com/phdpablo/arte) — Article Reproducibility Template & Environment — e a separação de fontes, dados, scripts e resultados do protocolo TIER.

### Principais características

- ✅ **Orientações metodológicas para AFC**, com justificativa das decisões e aplicação à WHOQOL-Bref.
- ✅ **Artigo executável em Quarto**, com análises em R e modelos estimados por `lavaan`.
- ✅ **Versões HTML e PDF**, com explicações e códigos em callouts no HTML.
- ✅ **Resultados persistidos**, para reaproveitar simulações e permutações ou recalculá-las de forma controlada.
- ✅ **Ambientes configurados com renv e Docker**, com versões e limites documentados.
- ✅ **Organização baseada no ARTE e no protocolo TIER**, separando fontes, entradas, dados derivados e resultados.

## Sobre o artigo

O artigo-tutorial tem três objetivos:

1. Sistematizar decisões analíticas de AFC fundamentadas na literatura, incluindo planejamento, avaliação e relato dos modelos.
2. Demonstrar essas decisões em uma aplicação empírica, com código R integrado às tabelas e figuras.
3. Disponibilizar dados, procedimentos e organização de arquivos para examinar, reproduzir e adaptar o percurso analítico.

**Principais temas:** seleção e fundamentação do modelo de medida; poder analítico e por Monte Carlo; triagem C/IER e dados ausentes; estimação MLR/FIML; ajuste global e local; confiabilidade; modificações fundamentadas; calibração, validação e invariância de medida.

**Palavras-chave:** Análise Fatorial Confirmatória, Modelagem de Equações Estruturais, Validade da Estrutura Interna, Ciência Aberta, Reprodutibilidade, Quarto e `lavaan`.

## Acesso aos materiais

| Recurso | Descrição | Acesso |
| --- | --- | --- |
| 📄 Preprint | Nova versão do artigo | Repositório e DOI a definir |
| 🌐 Artigo | Versão disponibilizada no site | [HTML](https://phdpablo.github.io/cfa-tutorial/) e [PDF](https://phdpablo.github.io/cfa-tutorial/cfa-tutorial.pdf) |
| 🐳 Docker | Imagem pronta para auditoria HTML/PDF | [Docker Hub](https://hub.docker.com/r/phdpablo/cfa-tutorial) e [instruções](docker/README.md) |
| 📝 Fontes | Resumo, seções, referências e estilo de citação | [Article/](Article/README.md) |
| 📊 Dados e resultados | Entradas, bases derivadas, simulações e exportações | [Data/](Data/README.md) e [Output/](Output/README.md) |
| 🔧 Código compartilhado | Modelos, helpers e persistência | [Scripts/](Scripts/README.md) |

O site publicado corresponde à versão disponibilizada remotamente. Um checkout com alterações locais pode conter conteúdo posterior.

## Estrutura do repositório

```text
cfa-tutorial/
├── index.qmd                 # Título do resumo e inclusão de Article/00_abstract.qmd
├── _quarto.yml               # Ordem das seções, formatos e caminhos do projeto
├── Article/                  # Resumo, seções 01–09, referências, BibTeX e CSL
├── Data/
│   ├── InputData/            # Dados de entrada e Metadata/
│   ├── IntermediateData/     # Etapas da triagem e oito resultados RDS
│   └── AnalysisData/         # Base de análise e partição calibração/validação
├── Scripts/
│   ├── DataAppendixScripts/  # Modelos, helpers e mecanismo de persistência
│   ├── ProcessingScripts/    # Pasta reservada; processamento está nos QMDs
│   └── AnalysisScripts/      # Pasta reservada; análises estão nos QMDs
├── Output/
│   ├── Results/              # Tables/ e Figures/ exportadas pelo artigo
│   └── DataAppendixOutput/   # Registro de exclusões em Tables/
├── renv.lock                 # Versões dos pacotes R
├── renv/                     # Ativação e configuração do ambiente R
├── .Rprofile                 # Ativa renv ao iniciar R na raiz
├── cfa-tutorial.Rproj        # Projeto RStudio/Positron
├── docker/                   # Dockerfile, Compose e lançadores de auditoria
└── cover.jpg                 # Capa e favicon
```

O repositório mantém `index.qmd` na raiz como página inicial. Os demais documentos estão em `Article/`. A árvore acima apresenta os arquivos-fonte e as pastas disponibilizados no repositório.


## Início rápido

### Ler o artigo publicado

Abra o [HTML](https://phdpablo.github.io/cfa-tutorial/) ou o [PDF](https://phdpablo.github.io/cfa-tutorial/cfa-tutorial.pdf). O HTML inclui callouts com código e explicações dos procedimentos.

### Escolher o nível de reprodução

Seguindo a organização do [ARTE 2.0](https://github.com/phdpablo/arte), há três caminhos para executar o CFA Tutorial. A leitura do artigo está disponível independentemente deles.

| Nível | Caminho | Preparação |
| --- | --- | --- |
| Mínima | Executar os arquivos em um ambiente R local preparado pelo leitor | Baixar o ZIP ou clonar o projeto e instalar as dependências necessárias |
| Adequada | Restaurar as versões dos pacotes R registradas no projeto | Usar R 4.5.2, Quarto 1.9.37 e `renv::restore()` |
| Máxima | Auditar o artigo no ambiente da imagem Docker publicada | Instalar e iniciar o Docker e executar `audit.bat` ou `audit.sh` |

Os níveis descrevem o controle do ambiente computacional. Nos três caminhos, as etapas demoradas podem reutilizar os oito RDS distribuídos; repetir integralmente as simulações é uma operação separada.

### Reprodução mínima: ambiente local

No GitHub, selecione **Code → Download ZIP** e extraia os arquivos, ou clone o repositório:

```bash
git clone https://github.com/phdpablo/cfa-tutorial.git
cd cfa-tutorial
```

Abra `cfa-tutorial.Rproj` e trabalhe na raiz do projeto. Este caminho exige R, Quarto, os pacotes utilizados nos QMDs e em `Scripts/DataAppendixScripts/helpers.R`, além de LaTeX para o PDF. O projeto ativa `renv` por `.Rprofile`; se a biblioteca ainda não estiver preparada, utilize a restauração descrita no próximo nível. Instalar versões diferentes por conta própria pode alterar os resultados ou impedir a execução.

### Reprodução adequada: dependências com renv

Instale R 4.5.2 e Quarto 1.9.37. Para trabalhar no RStudio, abra `cfa-tutorial.Rproj`. Mantenha o diretório de trabalho na raiz do projeto.

```bash
Rscript -e "renv::restore(prompt = FALSE)"
quarto --version
```

`.Rprofile` ativa o ambiente do projeto. `renv::restore()` instala as versões registradas no lockfile e pode precisar de acesso à internet e ferramentas de compilação, conforme o sistema operacional. Ele não instala a versão do executável R nem o Quarto. Consulte a [documentação de restauração do renv](https://pkgs.rstudio.com/renv/reference/restore.html).

Para gerar o PDF, prepare uma distribuição LaTeX. Se optar pelo TinyTeX:

```bash
quarto install tinytex --no-prompt
```

Para uma primeira conferência da configuração, sem executar os chunks:

```bash
quarto inspect
```

Para produzir o artigo:

```bash
quarto render --to html
quarto render --to pdf
```

Ou gere ambos os formatos com `quarto render --to all`. Abra o `index.html` e o `cfa-tutorial.pdf` gerados no diretório de saída definido em `_quarto.yml` para conferir a leitura. `quarto inspect` verifica a configuração, mas não comprova a execução analítica.

O render executa os QMDs na ordem de `book.chapters`. `execute-dir: project` e `here::here()` resolvem os caminhos R a partir da raiz. O pre-render `pre_render_cache.R` prepara `Data/IntermediateData/` e regrava a definição de `cache_load_existing()`; ele não executa simulações nem carrega automaticamente os RDS.

Alguns callouts contêm chunks executáveis recolhíveis; os exemplos com `eval: false` são demonstrativos. Não execute uma segunda vez o exemplo de uma rotina apenas por ele estar disponível no callout.

### Reprodução máxima: auditoria com Docker

Baixe ou clone o projeto e instale o Docker com suporte a containers Linux. Com o Docker em execução, rode na raiz do repositório:

```powershell
.\docker\audit.bat
```

Em Linux/macOS, use `bash docker/audit.sh`. Veja as instruções em [docker/README.md](docker/README.md).

## Ambiente Docker

O ambiente CFA Tutorial usa a imagem `phdpablo/cfa-tutorial:4.5.2`, baseada em `rocker/r-ver:4.5.2`, com Quarto 1.9.37, dependências de `renv.lock` e TinyTeX com TeX Live 2026. O serviço `audit` executa a cópia do artigo incorporada à imagem e exporta HTML, PDF e recursos para `docs` no computador do usuário.

Os lançadores reutilizam a imagem local ou baixam `phdpablo/cfa-tutorial:4.5.2` do [Docker Hub](https://hub.docker.com/r/phdpablo/cfa-tutorial) quando ela está ausente. Ao encerrar, o container é removido e a imagem permanece no computador. A construção pelo Dockerfile é uma alternativa separada, documentada em [docker/README.md](docker/README.md). O uso do ARTE 2.0 neste projeto concentra-se na auditoria: o serviço executa a renderização, verifica os produtos e encerra.

Os arquivos locais do artigo não são montados no container. A revisão incorporada à imagem determina o conteúdo auditado; alterações posteriores nos QMDs ou READMEs locais só passam a integrar a imagem após nova construção. `docs/audit-summary.txt` registra a execução e `docs/audit-inputs.sha256` identifica os insumos conferidos.

## Escopo de reprodução e versões

As versões abaixo são as registradas no checkout; não representam uma recomendação de atualizar para as versões mais recentes.

| Componente | Configuração |
| --- | --- |
| R principal | 4.5.2, conforme `renv.lock` e `docker/Dockerfile` |
| Quarto | 1.9.37, exigido por `_quarto.yml` e fixado no Dockerfile |
| renv | 1.2.4 |
| lavaan | 0.6-21 |
| semTools | 0.5-7 |
| semPower | 2.1.3 |
| simsem | 0.5-17 |
| dynamic | 1.1.0 |
| PDF | LaTeX; TinyTeX pode ser instalado pelo Quarto |
| Diagramas no PDF | Chrome Headless Shell, instalado no build do Docker principal |

O inventário completo de dependências está em [renv.lock](renv.lock). O Docker usa a versão de R do lockfile. A configuração TeX não congela uma versão datada do repositório de pacotes.

## Resultados salvos, renderização e recálculo

O projeto utiliza dois mecanismos independentes:

- **Freeze do Quarto:** `freeze: auto` permite reaproveitar execuções de QMDs em renderizações globais quando as fontes não mudaram. Alterações externas em dados ou scripts podem exigir execução explícita dos QMDs afetados. Renderizar um documento isolado executa seu código, independentemente de freeze. Veja [Managing Execution](https://quarto.org/docs/projects/code-execution.html).
- **Persistência RDS:** `cache_or_run()` procura primeiro o objeto pelo nome na sessão, depois o RDS em `Data/IntermediateData/`. Se ambos estiverem ausentes, executa a expressão e salva o resultado. Esse mecanismo continua atuando mesmo quando o Quarto executa novamente o documento.

Os oito RDS são distribuídos no repositório e permitem reaproveitar as etapas mais demoradas. Renderizar com eles ainda pode executar triagem, estimações, tabelas e exportações; não equivale a repetir todas as simulações. Consulte o [inventário por etapa](Data/IntermediateData/README.md).

Os parâmetros compartilhados atuais em `helpers.R` são `REP = 10`, `SEQ = rep(101:400, each = REP)`, `SIM = 1000`, `N_TARGET = 200` e `SEED = 123321`. Na seção 4 há 3.000 replicações por condição para N variável e 1.000 por condição para N fixo. As simulações empíricas da seção 7, o 3DFI e a permutação métrica da seção 8 também solicitam 1.000 replicações/permutações. A permutação está configurada com 28 processos; ajuste `ncpus` à capacidade da máquina antes de recalculá-la.

Para recalcular uma etapa de forma deliberada:

1. Identifique no QMD o resultado, os dados e os parâmetros envolvidos. Preserve uma cópia do RDS anterior fora de `Data/IntermediateData/`, com registro de sua configuração.
2. Inicie uma sessão R limpa ou remova da sessão os objetos de cache correspondentes. Retire de `Data/IntermediateData/` somente os RDS da etapa a recalcular. Mudar parâmetros não invalida automaticamente arquivos ou objetos existentes.
3. Execute o QMD correspondente, respeitando as dependências das seções anteriores. Para N variável ou fixo, as duas condições precisam corresponder à mesma configuração.
4. Confira o novo resultado e renderize os documentos dependentes. Não trate resultados de um ensaio curto como equivalentes aos da configuração do artigo.

`quarto render Article/04_pa.qmd --to html`, por exemplo, executa a seção, mas reaproveita seus RDS enquanto estiverem disponíveis. `--no-cache` não desativa `cache_or_run()` nem remove os arquivos persistidos. A partição de calibração/validação também é persistida: não a apague ou sorteie novamente para escolher resultados favoráveis.

## Dados e percurso analítico

O processamento parte de 1.546 registros, mantém 1.323 elegíveis após a etapa preliminar e retém 1.243 após os cinco critérios de C/IER. A seção 6 recupera a partição estratificada por ausência nos 24 indicadores: 621 participantes na calibração e 622 na validação. Esses totais descrevem os arquivos atuais; a tabela do artigo é gerada a partir dos dados.

As seções 6–7 estimam e avaliam os modelos originais na calibração. A seção 8 examina o modelo modificado de 21 indicadores na validação e a invariância entre as amostras. A divisão é uma avaliação interna de estabilidade; as decisões históricas sobre itens não devem ser apresentadas como seleção independente de toda a base original. A interpretação e as limitações metodológicas estão no artigo.

Os CSVs do projeto usam ponto e vírgula como delimitador. Para leitura em R, use `readr::read_csv2()`; exportações numéricas seguem convenções de `write_csv2()` ou `write_excel_csv2()`. A documentação de origem e as definições de variáveis estão em [Metadata/](Data/InputData/Metadata/README.md).

## Reutilizar a organização

Para adaptar o projeto, comece pelos dados e metadados de entrada, pelas especificações em `models.R` e pelos parâmetros em `helpers.R`. Reveja as decisões da triagem, os itens, as condições populacionais, a identificação e a estratégia de validação para a nova pesquisa. Depois recalcule os resultados dependentes e revise a narrativa e os exemplos. A reutilização de um RDS pressupõe correspondência entre dados, modelo e configuração.

Os helpers são documentados junto ao código em [helpers.R](Scripts/DataAppendixScripts/helpers.R); os READMEs indicam os papéis dos arquivos, sem duplicar um catálogo de funções. `ProcessingScripts/` e `AnalysisScripts/` estão reservadas: nesta versão, os próprios QMDs contêm o processamento e as análises.

## Ambientes alternativos e publicação

O [Docker](docker/README.md) permite executar a imagem pronta ou construí-la a partir do checkout selecionado. Os arquivos incorporados à imagem determinam a revisão auditada; alterações posteriores nas fontes locais exigem atualizar a imagem.

Para publicar o artigo no GitHub Pages a partir do branch de fontes, utilize:

```bash
quarto publish gh-pages
```

O repositório deve estar no GitHub, com autenticação e permissão de envio configuradas. Em **Settings → Pages**, selecione **Deploy from a branch**, o branch **gh-pages** e a pasta **/ (root)**. Se o branch ainda não existir, a primeira publicação pelo Quarto pode criá-lo; depois confirme essa configuração no GitHub. Execute o comando no branch de fontes, não no próprio `gh-pages`.

O comando renderiza e envia o conteúdo publicado ao branch `gh-pages`. A publicação é uma ação explícita, separada do commit dos arquivos-fonte. Consulte as [instruções do Quarto para GitHub Pages](https://quarto.org/docs/publishing/github-pages.html).

## Citação

A referência do novo preprint será completada após sua disponibilização. Até lá, os dados bibliográficos confirmados são:

> Rogers, P., & Georgeto, S. M. [Ano a definir]. *Planejamento e avaliação de modelos de análise fatorial confirmatória: um tutorial reprodutível com R e Quarto*. [Preprint; repositório e DOI a definir].

Para identificar a versão computacional utilizada, registre também o commit do repositório e a referência da imagem Docker, quando aplicável. O BibTeX será incluído quando os metadados do novo preprint estiverem definidos.

A infraestrutura deriva do ARTE. Referência: Rogers, P., & Limongi, R. (2025). Open Science in Three Acts: Foundations, Practice, and Implementation — Third Act. *BAR — Brazilian Administration Review*, 22(3), e250162. [DOI](https://doi.org/10.1590/1807-7692bar2025250162).

## Licença

O projeto é distribuído sob [CC BY-NC 4.0](LICENSE). A origem dos dados e a literatura utilizada devem ser reconhecidas ao reutilizar os materiais.
