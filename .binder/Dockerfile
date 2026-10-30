# Build from the repository root using the ready-made Binder environment.
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
# Fail at build time if the base image changes the Binder user or R version.
RUN test "$(id -u)" = "1000" \
    && R -s -e "stopifnot(getRversion() == '4.4.2')" \
    && jupyter server extension list
RUN R -s -e "renv::restore(prompt = FALSE)"
COPY --chown=rstudio:rstudio . .
# Build the audit HTML before opening the session; fail the build on render errors.
ENV QUARTO_PROFILE=binder
RUN quarto render --to html \
    && test -s docs/index.html

# Jupyter, the RStudio proxy and launch configuration come from rocker/binder.
