# This Dockerfile defines the reproducible computational environment
# for the CFA tutorial manuscript. The resulting image is self-contained:
# all project files, R packages, and LaTeX dependencies are embedded.
#
# The pre-built image is published on Docker Hub for end-user reproducibility.
# This file is included in the repository for transparency.

# --- Base Image ---
# rocker/verse includes R, RStudio Server, Quarto, Pandoc, and TinyTeX.
FROM rocker/verse:4.5.2

# --- Image Metadata ---
LABEL maintainer="Pablo Rogers <pablorogers@ufu.br>" \
      version="4.5.2" \
      description="Smart Choices for Measurement Models: CFA Tutorial in R" \
      url="https://doi.org/10.31234/osf.io/2dy3z"

# --- renv Configuration ---
# Set renv paths inside the user's home directory (no external volumes needed).
ENV RENV_PATHS_CACHE=/home/rstudio/renv/cache \
    RENV_PATHS_LIBRARY_ROOT=/home/rstudio/renv/library

WORKDIR /home/rstudio

# --- Step 1: Copy renv files and restore R packages ---
# Copy only renv configuration first to leverage Docker layer caching.
COPY --chown=rstudio:rstudio renv.lock .
COPY --chown=rstudio:rstudio .Rprofile .
COPY --chown=rstudio:rstudio renv/activate.R renv/

# Restore R packages as the rstudio user
USER rstudio
RUN R -s -e "renv::restore()"
USER root

# --- Step 2: Copy all project files ---
# Embed the entire project into the image for self-contained reproducibility.
COPY --chown=rstudio:rstudio . .

# --- Step 3: Fix ownership and permissions ---
WORKDIR /home/rstudio
RUN chown -R rstudio:rstudio /home/rstudio && \
    find /home/rstudio -type d -exec chmod 755 {} \; && \
    find /home/rstudio -type f -exec chmod 644 {} \;

# --- Step 4: Install additional LaTeX packages ---
# These packages are needed for rendering the manuscript to PDF.
RUN R -e "tinytex::tlmgr_install(c('amsfonts', 'unicode-math', 'booktabs', 'caption', 'float', 'pgf', 'environ', 'pdfcol', 'fontawesome5', 'tcolorbox', 'lualatex-math', 'luatexbase', 'amssymb')); tinytex::tlmgr_update()"

# --- Step 5: LaTeX initialization script ---
# Regenerates LaTeX formats on first container start to avoid runtime errors.
COPY init-latex.sh /init-latex.sh
RUN chmod +x /init-latex.sh

# Note: Port 8787 (RStudio Server) is exposed by the base image.
# The init-latex.sh script is called via the command directive in docker-compose.yml.