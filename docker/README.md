# Docker reproduction

Build the selected checkout with R 4.5.2 and Quarto **1.9.37**. Quarto is deliberately pinned; do not upgrade it automatically. This build includes the project sources, restores `renv.lock`, and installs TinyTeX. The current manuscript has no analytical R packages yet.

From the repository root:

```bash
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up -d
```

Open <http://127.0.0.1:8787>. In the RStudio terminal:

```bash
cd /home/rstudio
quarto --version
R --version
quarto render --to all
```

HTML and PDF are written to `docs/`. To test without starting RStudio:

```bash
docker run --rm --user rstudio --entrypoint /bin/bash smart-cfa-local:r4.5.2-q1.9.37 -lc 'cd /home/rstudio && quarto render --to all'
```

Rebuild after source changes. The Compose configuration builds this checkout instead of pulling an older prebuilt project image. No image is uploaded by these commands. `.dockerignore` excludes administrative files, local libraries and previous rendered output.

The container has its own copy of the project. Changes inside it are lost when the container is removed; this is a reproduction environment, not the source of record. `docker compose -f docker/docker-compose.yml stop` stops it without removal.

TinyTeX/TeX Live packages are downloaded during the build and may change upstream. Record the build date and tool versions when reporting a reproduction test. An exact historical environment additionally requires an archived image digest; a fixed R/Quarto version alone does not freeze the TeX distribution.

The `start` scripts start an existing environment (or build one if absent). Build explicitly after updates. They use the base image's standard RStudio startup; no custom LaTeX initialization hook is required by this configuration.
