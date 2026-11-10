# Ambiente Binder

## Visão geral

A configuração Binder prepara uma sessão interativa com R 4.4.2, Quarto 1.9.37 e TeX Live 2026. Jupyter e o proxy do RStudio são fornecidos pela imagem base pré-compilada `phdpablo/cfa-tutorial-binder:4.4.2` (hospedada no Docker Hub). O Dockerfile copia os arquivos do repositório da branch ativa (`pt_version`, `en_version`, etc.), garantindo que o ambiente computacional seja idêntico e compartilhado entre as versões, com tempo de inicialização de aproximadamente 1 minuto no mybinder.org.

## Conteúdo

| Arquivo | Função |
| --- | --- |
| `Dockerfile` | Constrói a imagem da sessão herdando da base pré-compilada e copiando os arquivos do artigo |

## Instruções de uso

### Testar localmente

Na raiz do projeto, construa a imagem e inicie a sessão:

```bash
docker build --platform linux/amd64 -f .binder/Dockerfile -t cfa-tutorial-binder .
docker run --rm -p 8888:8888 cfa-tutorial-binder
```

Copie a URL com token exibida no terminal para acessar o JupyterLab (`/lab`) ou RStudio (`/rstudio/`).

### Tentar o serviço público

Abra o [RStudio no Binder](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio) ou o [JupyterLab](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=lab). A primeira construção pode demorar, pois instala as dependências do artigo.

No terminal da sessão:

```bash
cd /home/rstudio
quarto render
```

As saídas ficam em `docs/index.html` e `docs/cfa-tutorial.pdf`. No painel Files do RStudio, abra o HTML para visualizar e baixe o PDF. A sessão é temporária; baixe os arquivos desejados antes de encerrá-la.

As análises reaproveitam os RDS distribuídos em `Data/IntermediateData/`. Para recalcular as simulações, consulte as [instruções de recálculo](../README.md#resultados-salvos-renderização-e-recálculo) e adeque o paralelismo aos recursos disponíveis.

O serviço utiliza o branch `pt_version` do GitHub. Para reproduzir uma revisão específica, substitua esse nome pelo SHA do commit na URL do Binder. A construção requer rede e está sujeita aos recursos do serviço público.
