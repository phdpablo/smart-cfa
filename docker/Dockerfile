# Build from the repository root with the same R version as renv.lock.
FROM rocker/verse:4.5.2

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

WORKDIR /home/rstudio
ENV RENV_PATHS_CACHE=/home/rstudio/.cache/renv \
    RENV_PATHS_LIBRARY_ROOT=/home/rstudio/renv/library
COPY --chown=rstudio:rstudio renv.lock .Rprofile ./
COPY --chown=rstudio:rstudio renv/activate.R renv/settings.json ./renv/
USER rstudio
RUN R -s -e "renv::restore(prompt = FALSE)"
# Install the current TinyTeX distribution through the pinned Quarto CLI.
# Record its version during validation; the TeX repository is not frozen.
RUN quarto install tinytex --no-prompt
# Keep the browser in the same user's tool directory used for rendering.
RUN quarto install chrome-headless-shell --no-prompt
# Fail during the build if the browser cannot start with the installed libraries.
RUN browser="$(find "$HOME/.local/share/quarto" -type f -name chrome-headless-shell -print -quit)" \
    && test -n "$browser" \
    && timeout 30s "$browser" --no-sandbox --disable-gpu --dump-dom about:blank > /dev/null
COPY --chown=rstudio:rstudio . .

# Restore the base image startup user for RStudio Server.
USER root
