# Ambiente Binder

## Visão geral

[Abrir o branch pt_version no Binder](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio).

O serviço utiliza os arquivos enviados ao GitHub. Alterações locais só estarão disponíveis depois de commit/push. Para identificar uma reprodução específica, substitua `pt_version` na URL pelo SHA completo do commit.

## Conteúdo

O único arquivo de construção nesta pasta é `Dockerfile`. Ele usa `rocker/verse:4.5.2`, acrescenta Jupyter Notebook, JupyterLab, JupyterHub e `jupyter-rsession-proxy` em um ambiente Python separado, instala Quarto 1.9.37 e TinyTeX, restaura `renv.lock` e copia o checkout para `/home/rstudio`. O proxy mantém o acesso ao RStudio pelo endereço `?urlpath=rstudio`.

Binder, Docker principal e lockfile usam R 4.5.2. Isso atende ao requisito R >= 4.5 de `Deriv 4.3.5`. A imagem `rocker/binder:4.5.2` não está disponível; por isso os serviços Binder são instalados sobre a imagem versionada `verse`, que já fornece RStudio Server. O build verifica o UID 1000 do usuário e a versão de R e remove o entrypoint herdado para aceitar o comando de inicialização do Binder. A versão de `RcppParallel` foi preservada em 6.2.1, com origem CRAN em vez de ZIP local de Windows. Estas correções não equivalem a um novo build completo ou teste do serviço público.

## Instruções de uso

No terminal do RStudio da sessão:

```bash
cd /home/rstudio
R --version
quarto --version
quarto render --to html
quarto render --to pdf
```

As saídas ficam em `docs/`, com a entrada `index.html`, capítulos em `Article/` e o PDF `cfa-tutorial.pdf`. As sessões são temporárias; baixe os arquivos desejados antes de encerrá-las.

Os oito RDS distribuídos permitem reaproveitar as etapas demoradas. Se forem retirados ou não estiverem disponíveis, o código pode iniciar simulações ou a permutação métrica. A chamada atual de permutação usa 28 processos; não a recalcule nessa configuração sem adequar os recursos ao ambiente. Para entender o reaproveitamento, consulte o [README principal](../README.md#resultados-salvos-renderização-e-recálculo).

O build precisa de rede para pacotes e TeX e pode ser limitado pelos recursos do serviço. Uma sessão iniciada com sucesso não comprova recomputação integral dos resultados, e um build local do Dockerfile não certifica o funcionamento do serviço Binder.
