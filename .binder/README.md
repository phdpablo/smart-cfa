# Ambiente Binder

## Visão geral

[Abrir o branch pt_version no Binder](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio).

O serviço utiliza os arquivos enviados ao GitHub. Alterações locais só estarão disponíveis depois de commit/push. Para identificar uma reprodução específica, substitua `pt_version` na URL pelo SHA completo do commit.

## Conteúdo

O único arquivo de construção nesta pasta é `Dockerfile`. Ele usa `rocker/binder:4.4.2`, instala Quarto 1.9.37 e TinyTeX, restaura `renv.lock` e copia o checkout para `/home/rstudio`.

O lockfile registra R 4.5.2 e já contém os pacotes analíticos. A diferença em relação ao R 4.4.2 do Binder é uma condição de compatibilidade a verificar; não se deve presumir que os testes de uma versão anterior certificam o conjunto atual de dependências. Nesta revisão documental não foi feito novo build nem teste do serviço público.

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
