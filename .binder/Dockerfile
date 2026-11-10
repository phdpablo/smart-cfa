# --- Base image ---
# Build from the precompiled Binder base image hosted on Docker Hub.
# Provides R 4.4.2, pre-restored renv packages (including OpenMx & semPlot),
# Quarto 1.9.37, TinyTeX 2026, Chrome Headless Shell, JupyterLab & RStudio proxy.
FROM phdpablo/cfa-tutorial-binder:4.4.2

LABEL maintainer="Pablo Rogers <pablorogers@ufu.br>" \
      org.opencontainers.image.title="CFA Tutorial" \
      version="4.4.2" \
      description="RStudio/Quarto environment for CFA Tutorial."

# --- Article inputs ---
USER root
WORKDIR /home/rstudio

# Copy the repository files from the active branch (e.g. pt_version or en_version)
COPY --chown=rstudio:rstudio . .

# --- Binder startup: inherit JupyterLab and the RStudio proxy ---
USER rstudio
ENTRYPOINT []
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser"]
