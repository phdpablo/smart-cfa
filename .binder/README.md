# Ambiente Binder

## Visão geral

O Binder disponibiliza uma sessão temporária para renderizar o artigo no navegador, sem instalar R no computador. O ambiente usa R 4.4.2, Quarto 1.9.37 e TeX Live 2026. Jupyter e RStudio são fornecidos pela imagem `rocker/binder:4.4.2`.

## Conteúdo

| Arquivo | Função |
| --- | --- |
| `Dockerfile` | Prepara as dependências R, o navegador para diagramas e as ferramentas de PDF, e copia o artigo |

O Dockerfile restaura `Matrix` antes dos demais pacotes de `renv.lock`. O lockfile inclui `Deriv 4.2.0`, compatível com o requisito de R do ambiente, além dos pacotes de links de código e GLB. Os arquivos copiados são filtrados pelo `.dockerignore` da raiz.

## Instruções de uso

Abra o [RStudio no Binder](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio) ou o [JupyterLab](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=lab). A primeira construção pode demorar, pois instala as dependências do artigo.

No terminal da sessão:

```bash
cd /home/rstudio
quarto render
```

As saídas ficam em `docs/index.html` e `docs/cfa-tutorial.pdf`. No painel Files do RStudio, abra o HTML para visualizar e baixe o PDF. A sessão é temporária; baixe os arquivos desejados antes de encerrá-la.

As análises reaproveitam os RDS distribuídos em `Data/IntermediateData/`. Para recalcular as simulações, consulte as [instruções de recálculo](../README.md#resultados-salvos-renderização-e-recálculo) e adeque o paralelismo aos recursos disponíveis.

O serviço utiliza o branch `pt_version` do GitHub. Para reproduzir uma revisão específica, substitua esse nome pelo SHA do commit na URL do Binder. A construção requer rede e está sujeita aos recursos do serviço público.
