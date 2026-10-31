# CFA Tutorial — reprodução com Docker

## Visão geral

O ambiente inclui R 4.5.2, Quarto 1.9.37, os pacotes de `renv.lock` e as ferramentas necessárias para gerar o artigo em HTML e PDF. Instale Docker Desktop e mantenha o mecanismo Linux em execução. A construção da imagem requer conexão com a internet.

## Conteúdo

| Arquivo | Função |
| --- | --- |
| `Dockerfile` | Constrói a imagem com as dependências e uma cópia do artigo |
| `docker-compose.yml` | Define a construção e execução do container e a porta do RStudio |
| `start.bat` / `start.sh` | Iniciam o ambiente, aguardam o RStudio e abrem o navegador |
| `stop.bat` / `stop.sh` | Param o container sem removê-lo |

O [`.dockerignore` da raiz](../.dockerignore) filtra os arquivos enviados à construção da imagem.

## Instruções de uso

### Construir e iniciar

Na raiz do repositório:

```bash
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up -d
```

A imagem é `cfa-tutorial:4.5.2` e o container é `cfa-tutorial`.

Também é possível usar os atalhos:

| Sistema | Iniciar | Parar |
| --- | --- | --- |
| Windows | `docker/start.bat` | `docker/stop.bat` |
| Linux/macOS | `bash docker/start.sh` | `bash docker/stop.sh` |

No Windows, os arquivos `.bat` também podem ser abertos com duplo clique. Os scripts localizam o Compose pela própria pasta e podem ser chamados de qualquer diretório. O start constrói a imagem caso ela não exista, aguarda o RStudio responder e abre o navegador.

### Renderizar o artigo

Acesse [RStudio Server](http://127.0.0.1:8787). No terminal do RStudio:

```bash
cd /home/rstudio
quarto render
```

As saídas são `docs/index.html` e `docs/cfa-tutorial.pdf`. As análises reaproveitam os resultados RDS distribuídos em `Data/IntermediateData/`. Consulte o [README principal](../README.md#resultados-salvos-renderização-e-recálculo) para recalcular as simulações.

### Exportar os resultados

O container trabalha com uma cópia do projeto. Para copiar as saídas para o computador, execute no terminal do host:

```bash
docker cp cfa-tutorial:/home/rstudio/docs ./docker-render-output
```

### Parar e atualizar

Para parar sem remover o container:

```bash
docker compose -f docker/docker-compose.yml stop
```

Os arquivos permanecem no mesmo container entre parada e início. Antes de removê-lo ou recriá-lo, exporte as alterações que desejar conservar.

Depois de alterar as fontes, o lockfile ou o Dockerfile, execute novamente os comandos de construção e início. Os atalhos reutilizam uma imagem existente e não a reconstroem automaticamente.
