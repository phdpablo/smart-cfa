# Auditoria do ambiente renv — 30/10/2026

## Correções posteriores autorizadas — 30/10/2026

As duas incompatibilidades identificadas abaixo receberam correção: RcppParallel 6.2.1 agora tem Source = Repository e Repository = CRAN, sem RemoteType/RemoteUrl locais; a fonte CRAN da mesma versão respondeu HTTP 200. Binder passou a rocker/verse:4.5.2 com serviços Jupyter/RStudio proxy, porque a tag rocker/binder:4.5.2 não existe no Docker Hub/GHCR consultados. A base verse:4.5.2 foi confirmada no registro. README principal e do Binder foram sincronizados. As demais versões do lockfile foram preservadas. Não houve instalação na biblioteca local, atualização analítica ou build completo; a descrição de problemas abaixo registra o diagnóstico anterior às correções.

Escopo: lockfile, declarações de dependências nas fontes Article/Scripts, ativação/configuração renv e Dockerfiles. Não foram apagados/recriados lockfiles, instalados/atualizados pacotes ou executados builds. A falha específica do container não foi reproduzida nem seu log fornecido.

## Resultado

- renv.lock, .Rprofile, renv/activate.R e renv/settings.json estão rastreados pelo Git.
- R registrado e local: 4.5.2. renv registrado/ativado: 1.2.4. snapshot.type: implicit; campos transitivos: Depends, Imports e LinkingTo.
- Detectados 27 nomes de pacotes diretamente nas fontes, incluindo pacotes de base e rmarkdown inferido pelo scanner para QMDs. A cadeia recursiva desses pacotes e renv alcança todos os 200 registros do lockfile.
- Nenhum registro excedente fora dessa cadeia; nenhum pacote obrigatório não-base ausente do lockfile nessa análise estática. Isso não comprova ausência de dependências carregadas dinamicamente não detectáveis pelo scanner.
- renv::status(), executado fora do sandbox, informou: “No issues found -- the project is in a consistent state.” O diagnóstico dentro do sandbox listou pacotes como ausentes apesar de seus DESCRIPTION existirem; esse resultado era uma limitação de acesso e não deve ser apresentado como ausência real.

## Problemas concretos de portabilidade

1. **RcppParallel 6.2.1** está registrado com Source = Local, RemoteType = local e RemoteUrl = _temp/model-fit/packages/RcppParallel_6.2.1.zip. O ZIP existe nesta máquina, mas _temp é ignorada pelo Git e excluída no .dockerignore. Os Dockerfiles executam restore antes do COPY geral e não copiam esse arquivo na camada de restore. Um binário ZIP de Windows também não fornece o pacote Linux correspondente. Essa origem precisa ser substituída por fonte remota restaurável/portável, conferindo a mesma versão e a compatibilidade antes de alterar o lockfile.
2. **Binder incompatível com requisito declarado**: .binder/Dockerfile usa R 4.4.2, enquanto Deriv no lockfile exige R >= 4.5. Não é apenas diferença nominal de versões; o requisito não é satisfeito. Docker principal usa R 4.5.2 e satisfaz esse requisito. Corrigir requer decisão sobre a versão do Binder ou uma combinação compatível de pacotes; não foi feito automaticamente.

## Por que há tantos pacotes

| Dependência | Origem na cadeia declarada |
| --- | --- |
| OpenMx | semPlot |
| StanHeaders | semPlot → OpenMx |
| RcppEigen | semPlot/OpenMx e car/lme4 |
| RcppParallel | semPlot/OpenMx/StanHeaders e dynamic/qs2/stringfish |
| Bayesrel | dynamic |
| testthat | dynamic → SimDesign |
| RUnit | semPlot → kutils |
| audio | dynamic → SimDesign/beepr |

Não eliminar esses registros só porque não aparecem em chamadas diretas. Reduzir significativamente a cadeia exige reconsiderar os pacotes de nível superior ou sua implementação, e não apagar dependências obrigatórias do lockfile.

## Container e limites

Os registros incluem requisitos de compilação e bibliotecas do sistema: OpenMx/qs2/stringfish usam C++17; RcppParallel e nloptr citam CMake; XML exige libxml2; png/jpeg requerem bibliotecas de imagem. Os Dockerfiles não têm uma camada apt explícita para esses requisitos; a imagem base pode já oferecer parte deles. Sem executar o build ou ler o log, não é possível atribuir a falha a uma biblioteca específica nem afirmar quais faltam.

Há registros de repositórios CRAN/RSPM e dynamic fixado em um commit GitHub. A origem GitHub fixada por SHA não é excesso por si só; acesso à rede e disponibilidade da fonte continuam necessários.

## Encaminhamento recomendado

Preservar o lockfile funcional como referência. Corrigir pontualmente a origem local de RcppParallel e resolver a incompatibilidade do Binder; depois testar restore em ambiente Linux limpo e examinar o primeiro erro real de compilação/instalação. Apenas então ajustar requisitos do sistema. Se houver snapshot, usar escopo implicit e revisar o diff, preservando versões testadas. Deletar o lockfile e recriá-lo nesta máquina não corrige a origem local registrada no pacote instalado e pode capturá-la novamente.

Esta auditoria não autoriza mudanças de versões, instalação, atualização de imagem ou recomputação das análises.
