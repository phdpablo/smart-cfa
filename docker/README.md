# Ambiente Docker local

## Visão geral

Esta configuração constrói o checkout selecionado com `rocker/verse:4.5.2`, Quarto 1.9.37, os pacotes analíticos de `renv.lock` e TinyTeX. O número de versão do Docker Desktop não é uma versão de dependência fixada pelo projeto; utilize Docker com o comando `docker compose` disponível.

## Conteúdo

| Arquivo | Função |
| --- | --- |
| `Dockerfile` | Instala Quarto/TinyTeX, restaura o lockfile e copia o projeto |
| `docker-compose.yml` | Serviço `article`, imagem `smart-cfa-local:r4.5.2-q1.9.37`, container `smart-cfa` |
| `start.bat` / `start.sh` | Executam `compose up -d` e tentam abrir o navegador |
| `stop.bat` / `stop.sh` | Param o container sem removê-lo |

## Instruções de uso

### Construção e execução

Na raiz do repositório:

```bash
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up -d
```

Abra [RStudio Server local](http://127.0.0.1:8787). O Compose associa a porta somente a `127.0.0.1` e define `DISABLE_AUTH=true`. No terminal do RStudio:

```bash
cd /home/rstudio
R --version
quarto --version
quarto render --to html
quarto render --to pdf
```

As saídas são `docs/index.html`, os capítulos em `docs/Article/` e `docs/cfa-tutorial.pdf`. Os oito RDS versionados são copiados no build; se faltarem, as respectivas simulações/permutação serão executadas. A permutação métrica solicita 28 processos no QMD; adeque esse parâmetro aos recursos do container antes de recalcular.

### Persistência dos arquivos

Os atalhos usam `docker-compose.yml` relativo ao diretório corrente; execute-os de dentro de `docker/`. Eles não garantem rebuild de uma imagem já existente. Após mudanças no código, lockfile ou resultados, rode novamente o comando explícito de build a partir da raiz.

O Compose não configura volume com o checkout do host. O container usa uma cópia; alterações feitas dentro dele não atualizam o repositório local. Para copiar a saída antes de remover o container, use, a partir da raiz:

```bash
docker cp smart-cfa:/home/rstudio/docs ./docker-render-output
docker compose -f docker/docker-compose.yml stop
```

O destino `docker-render-output` é apenas uma cópia local escolhida por esse comando; não é a pasta de publicação do projeto. Preserve o que precisar antes de remover ou recriar o container.

`.dockerignore` exclui bibliotecas locais, resultados renderizados anteriores e arquivos administrativos. `init-latex.sh`, na raiz, é um arquivo legado e não é chamado pelo Dockerfile ou Compose atuais; a configuração usa a inicialização padrão da imagem base.

### Escopo da reprodução

O build restaura o lockfile atual, que já contém os pacotes analíticos; não se trata mais de um manuscrito sem computações. A distribuição TeX e os tags das imagens podem receber alterações upstream. Para relatar um teste, registre commit, data, versões e digest da imagem.

Esta atualização documental conferiu a configuração, mas não executou um novo build ou render dentro de Docker. A auditoria integral do ambiente permanece uma etapa própria. As instruções gerais de reaproveitamento/recálculo estão no [README principal](../README.md#resultados-salvos-renderização-e-recálculo).
