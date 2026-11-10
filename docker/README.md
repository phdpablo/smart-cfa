# CFA Tutorial — reprodução com Docker

## Visão geral

A imagem de auditoria usa `rocker/r-ver:4.5.2`, Quarto 1.9.37, os pacotes de `renv.lock` e as ferramentas de HTML/PDF. O serviço executa o artigo incorporado à imagem e exporta os documentos para a pasta `docs` do projeto local. As simulações reaproveitam os oito RDS distribuídos.

## Conteúdo

| Arquivo | Função |
| --- | --- |
| `Dockerfile` | Constrói o ambiente e incorpora os arquivos do artigo |
| `docker-compose.yml` | Define o serviço único `audit` e o destino local `docs` |
| `audit.bat` | Executa a auditoria no Windows |
| `audit.sh` | Executa a auditoria no Linux/macOS |
| `audit-render.sh` | Rotina interna da imagem: renderiza, confere os produtos e exporta os resultados |

O [`.dockerignore` da raiz](../.dockerignore) filtra o contexto de construção. O usuário executa somente o lançador correspondente ao seu sistema.

## Instruções de uso

Instale e inicie o Docker com suporte a containers Linux. Na raiz do projeto, execute:

```powershell
.\docker\audit.bat
```

No Linux/macOS:

```bash
bash docker/audit.sh
```

Os lançadores localizam o Compose pela própria pasta. A imagem padrão é `phdpablo/cfa-tutorial:4.5.2`; a variável `CFA_IMAGE` permite selecionar outra referência compatível. Uma imagem local com essa tag é reutilizada. Se estiver ausente, o Docker baixa a imagem publicada no [Docker Hub](https://hub.docker.com/r/phdpablo/cfa-tutorial).

O serviço gera HTML e PDF dentro do container e exporta `docs` somente após o sucesso da renderização e das verificações. Os principais produtos são `docs/index.html`, `docs/cfa-tutorial.pdf`, `docs/audit-summary.txt` e `docs/audit-inputs.sha256`. A exportação pode substituir arquivos existentes em `docs`. Em caso de falha, consulte as mensagens do terminal; os produtos locais de uma execução anterior podem continuar na pasta.

O container é removido ao encerrar e a imagem permanece disponível para outras execuções. Não há etapa separada de parada nem abertura de RStudio ou Jupyter. Os arquivos-fonte do computador não são montados no container: alterações locais no artigo exigem atualizar a imagem para serem auditadas.

A receita de construção é disponibilizada para quem quiser incorporar suas próprias alterações. Essa etapa é opcional para usar a imagem publicada. Para construir uma nova imagem, execute separadamente, a partir da raiz:

```bash
docker build --platform linux/amd64 --progress=plain -f docker/Dockerfile -t phdpablo/cfa-tutorial:4.5.2 .
```

A construção requer internet e restaura o lockfile. Os lançadores de auditoria não constroem nem publicam imagens.
