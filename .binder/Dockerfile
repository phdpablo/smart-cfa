# Build from the repository root; keep the Binder R 4.4.2 compatibility target.
FROM rocker/binder:4.4.2

USER root
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
COPY --chown=rstudio:rstudio . .
