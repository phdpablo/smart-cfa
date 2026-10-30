# Build from the repository root with the same R version as renv.lock.
# rocker/binder has no 4.5.2 tag; add Binder services to the versioned verse image.
FROM rocker/verse:4.5.2

USER root
# Provide Jupyter and the RStudio proxy required by Binder.
ENV VIRTUAL_ENV=/opt/binder-venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-venv \
    && python3 -m venv "${VIRTUAL_ENV}" \
    && python3 -m pip install --no-cache-dir \
        notebook==7.6.4 \
        jupyterlab==4.6.5 \
        jupyterhub==6.1.1 \
        jupyter-rsession-proxy==2.5.1 \
    && rm -rf /var/lib/apt/lists/*
# Deliberately pinned: change only after an explicit project decision.
ENV QUARTO_VERSION=1.9.37
RUN curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

WORKDIR /home/rstudio
ENV NB_USER=rstudio \
    NB_UID=1000 \
    USER=rstudio \
    HOME=/home/rstudio
ENV RENV_PATHS_CACHE=/home/rstudio/.cache/renv \
    RENV_PATHS_LIBRARY_ROOT=/home/rstudio/renv/library
COPY --chown=rstudio:rstudio renv.lock .Rprofile ./
COPY --chown=rstudio:rstudio renv/activate.R renv/settings.json ./renv/
USER rstudio
# Fail at build time if the base image changes the Binder user or R version.
RUN test "$(id -u)" = "1000" \
    && R -s -e "stopifnot(getRversion() == '4.5.2')" \
    && jupyter server extension list
RUN R -s -e "renv::restore(prompt = FALSE)"
# Install the current TinyTeX distribution through the pinned Quarto CLI.
# Record its version during validation; the TeX repository is not frozen.
RUN quarto install tinytex --no-prompt
COPY --chown=rstudio:rstudio . .

# Binder supplies the Jupyter command and connection arguments at launch.
ENTRYPOINT []
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
