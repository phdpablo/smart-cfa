# Ambiente Binder

## Visão geral

[Abrir o branch pt_version no Binder](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio).

O serviço utiliza os arquivos enviados ao GitHub. Alterações locais só estarão disponíveis depois de commit/push. Para identificar uma reprodução específica, substitua `pt_version` na URL pelo SHA completo do commit.

## Conteúdo

O único arquivo de construção nesta pasta é `Dockerfile`. Ele usa `rocker/binder:4.4.2`, que já fornece Jupyter e o proxy para RStudio, instala Quarto 1.9.37, TinyTeX e Chrome Headless Shell, restaura `renv.lock` e copia o checkout para `/home/rstudio`. O proxy mantém o acesso ao RStudio pelo endereço `?urlpath=rstudio`.

Chrome Headless Shell é instalado durante o build como usuário `rstudio`, o mesmo da sessão. Ele permite ao Quarto converter os diagramas Graphviz em PNG para o PDF. O usuário não precisa instalar um navegador ao executar `quarto render`. Assim como TinyTeX, a versão do navegador baixado pelo instalador não é congelada pelo lockfile R.

O build instala também as bibliotecas Linux NSS/NSPR, ATK/AT-SPI, X11, xkbcommon, GBM e ALSA exigidas pelo navegador. Após a instalação, inicia o Chrome para ler uma página vazia, com limite de 30 segundos; assim, uma falha de bibliotecas compartilhadas interrompe o build antes da sessão do usuário.

Binder usa R 4.4.2; o ambiente local, Docker principal e a versão de R registrada no lockfile permanecem em 4.5.2. Para compatibilidade com Binder, `Deriv` foi fixado em 4.2.0, uma implementação em R sem o requisito R >= 4.5 de 4.3.5. O teste de derivação e o carregamento de `doBy` e `mirt` passaram no R local 4.5.2. A renderização e o novo build no Binder 4.4.2 ainda precisam ser validados. `RcppParallel 6.2.1` mantém origem CRAN, sem depender de ZIP local de Windows.

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
