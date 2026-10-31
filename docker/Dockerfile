# --- Base image ---
# Build from the repository root; verse supplies RStudio, Pandoc and LaTeX.
FROM rocker/verse:4.5.2

LABEL maintainer="Pablo Rogers <pablorogers@ufu.br>" \
      org.opencontainers.image.title="CFA Tutorial" \
      version="4.5.2" \
      description="RStudio/Quarto environment for CFA Tutorial."

# --- Project tools ---
USER root
# Runtime libraries required by Chrome Headless Shell on Ubuntu 24.04.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libnss3 libnspr4 libgbm1 libasound2t64 \
        libatk1.0-0t64 libatk-bridge2.0-0t64 libatspi2.0-0t64 \
        libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*
# Deliberately pinned: change only after an explicit project decision.
ENV QUARTO_VERSION=1.9.37
RUN curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

# --- renv configuration and project directory ---
ENV RENV_PATHS_CACHE=/renv/cache \
    RENV_PATHS_LIBRARY=/renv/library \
    RENV_CONFIG_SANDBOX_ENABLED=FALSE
RUN mkdir -p /home/rstudio /renv/cache /renv/library \
    && chown -R rstudio:rstudio /home/rstudio /renv
WORKDIR /home/rstudio
# --- Restore project packages ---
COPY --chown=rstudio:rstudio renv.lock .Rprofile ./
COPY --chown=rstudio:rstudio renv/activate.R renv/settings.json ./renv/
USER rstudio
# Stabilize the recommended Matrix package before restoring its dependants.
# The container supplies system isolation; use its actual default R library.
RUN R -s -e "renv::restore(packages = 'Matrix', prompt = FALSE)" \
    && R -s -e "library(Matrix); stopifnot(file.exists(system.file('libs', 'Matrix.so', package = 'Matrix')))"
RUN R -s -e "renv::restore(prompt = FALSE)" \
    && R -s -e "invisible(lapply(c('Matrix', 'vegan', 'mirt', 'dynamic'), loadNamespace))"
# --- PDF tools: current TeX Live, independent of the base image's old release ---
# Installing without system symlinks avoids sudo during user-level setup.
RUN R -s -e "tinytex::install_tinytex(dir = '/home/rstudio/.TinyTeX', force = TRUE, add_path = FALSE)"
ENV PATH="/home/rstudio/.TinyTeX/bin/x86_64-linux:${PATH}"
RUN tlmgr --version | grep 'TeX Live.*2026' \
    && tlmgr update --self --all \
    && tlmgr install amsfonts unicode-math booktabs caption float pgf environ pdfcol \
        fontawesome5 tcolorbox fvextra footnotehyper lm luatexbase babel-portuges \
        selnolig tikzfill hyphen-portuguese \
    && luaotfload-tool --update --force

# The DOT figure requires a browser when rendering PDF.
RUN quarto install chrome-headless-shell --no-prompt
RUN browser="$(find "$HOME/.local/share/quarto" -type f -name chrome-headless-shell -print -quit)" \
    && test -n "$browser" \
    && timeout 30s "$browser" --no-sandbox --disable-gpu --dump-dom about:blank > /dev/null

# --- Article inputs: no host caches, Git metadata or environment secrets ---
COPY --chown=rstudio:rstudio . .

# --- Standard Rocker startup; no custom entrypoint or persistent mounts ---
USER root
