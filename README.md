# Smart Choices for Measurement Models: Executable Manuscript Tutorial for your CFA in R Environment

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/main) [![Cite Preprint](https://img.shields.io/badge/Cite%20Preprint-PDF-red)](https://doi.org/10.31234/osf.io/2dy3z) [![TIER Protocol 4.0](https://img.shields.io/badge/TIER%20Protocol-4.0-green)](https://www.projecttier.org/tier-protocol/protocol-4-0/) [![GitHub Pages](https://img.shields.io/github/deployments/phdpablo/smart-cfa/github-pages?label=GitHub%20Pages)](https://phdpablo.github.io/smart-cfa/) [![OSF](https://img.shields.io/badge/OSF-10.31234/osf.io/2dy3z-blue)](https://doi.org/10.31234/osf.io/2dy3z) [![License](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/) [![R version](https://img.shields.io/badge/R-4.5.2-orange)](https://www.r-project.org/) [![Quarto](https://img.shields.io/badge/Quarto-1.6-orange)](https://quarto.org/) [![Docker](https://img.shields.io/badge/Docker-4.45.0-orange)](https://www.docker.com/) [![renv](https://img.shields.io/badge/renv-1.1.8-orange)](https://rstudio.github.io/renv/)

> Rogers, P., & Georgeto, S. M. (2024). *Smart Choices for Measurement Models: Executable Manuscript Tutorial for your Confirmatory Factor Analysis in R Environment.* <https://doi.org/10.31234/osf.io/2dy3z>

This repository contains the **fully reproducible source code** for the tutorial article on Confirmatory Factor Analysis (CFA) using R. The article guides applied social scientists through key decisions in CFA — from measurement model selection and power analysis to estimation, model fit, and modification — within a dynamic document framework that promotes open science principles (reproducibility, replicability, and transparency).

The manuscript is structured as a Quarto book and built using the [ARTE template](https://github.com/phdpablo/article-template) (Article Reproducibility Template & Environment), which encapsulates the entire computational environment via Docker and `renv`. The live rendered version is available at: <https://phdpablo.github.io/smart-cfa/>


## Table of Contents

- [About the Article](#about-the-article)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start (Using Docker - Recommended)](#quick-start-using-docker---recommended)
- [Setup, Build, and Run (Detailed Docker Steps)](#setup-build-and-run-detailed-docker-steps)
- [Accessing the RStudio Environment](#accessing-the-rstudio-environment)
- [Daily Workflow](#daily-workflow)
- [Environment Features](#environment-features)
- [Useful Commands](#useful-commands)
- [Troubleshooting](#troubleshooting)
- [Verify Reproducibility with MyBinder](#verify-reproducibility-with-mybinder)
- [Publishing / Deployment](#publishing--deployment)
- [Citation](#citation)
- [License](#license)

## About the Article

This tutorial article pursues three objectives:

1. **Compile guidelines** for applying CFA — a widely used technique in applied social sciences — covering recommended practices, pitfalls to avoid, and reporting standards.
2. **Demonstrate** these guidelines through a real-world example implemented entirely in R with the `lavaan` package.
3. **Structure the narrative** using open science tools (Quarto, renv, Docker, GitHub) to ensure reproducibility, replicability, and transparency.

**Key topics covered:**

- Measurement model selection and theoretical justification
- Power analysis for CFA
- Data pre-processing (missing data, outliers, assumptions)
- Estimation procedures (ML and robust variants for continuous items)
- Model fit evaluation (global and local fit indices)
- Model comparisons and modifications

**Keywords:** Confirmatory Factor Analysis, Structural Equation Modeling, Internal Structure Validity, Open Science, `lavaan`.

## Repository Structure

The project follows the [TIER Protocol 4.0](https://www.projecttier.org/tier-protocol/protocol-4-0/) folder structure:

```
smart-cfa/
├── index.qmd              # Abstract
├── 01-intro.qmd           # Introduction
├── 02-background.qmd      # Smart Choices in CFA (guidelines)
├── 03-methods.qmd         # Executable Manuscript (R tutorial)
├── 04-results.qmd         # Results
├── 05-conclusion.qmd      # Final Considerations
├── references.qmd         # References
├── _quarto.yml            # Quarto project configuration
├── references.bib         # BibTeX references
├── apa7ed.csl             # APA 7th edition citation style
├── render_cleanup.R       # Post-render cleanup script
├── Data/                  # Input, intermediate, and analysis data
├── Scripts/               # Processing, analysis, and appendix scripts
├── Output/                # Results and data appendix outputs
├── docker/                # Docker environment files
└── .binder/               # MyBinder configuration
```

Each subdirectory under `Data/`, `Scripts/`, and `Output/` contains a `README.md` with an overview, contents, and guidelines.

## Prerequisites

For **Full Reproducibility** (recommended), you only need:

1. **Docker:** [Download Docker Desktop](https://docs.docker.com/get-docker/) and ensure it is running.
2. **Git (Optional):** For cloning the repository. [Download Git](https://git-scm.com/downloads)

## Quick Start (Using Docker - Recommended)

1. **Get the repository:**
   ```bash
   git clone https://github.com/phdpablo/smart-cfa.git
   cd smart-cfa
   ```
   Or download the ZIP from the GitHub page.

2. **Navigate to the Docker directory:**
   ```bash
   cd docker
   ```

3. **Start the environment:**
   - **Windows:** Double-click `start.bat`
   - **macOS/Linux:** `./start.sh` (run `chmod +x start.sh` first if needed)

4. **Access RStudio:** Your browser opens automatically at `http://127.0.0.x:8787`. Project files are at `/home/rstudio/project`.

5. **Render the manuscript:**
   ```bash
   quarto render
   ```

6. **Stop the environment:**
   - **Windows:** Double-click `stop.bat`
   - **macOS/Linux:** `./stop.sh`

## Setup, Build, and Run (Detailed Docker Steps)

```bash
cd docker
docker-compose build      # (Optional) Build the image explicitly
docker-compose up -d      # Start the container
docker-compose down       # Stop and remove the container
```

## Accessing the RStudio Environment

- **URL:** `http://127.0.0.x:8787`
- **Authentication:** None required (`DISABLE_AUTH=true`)
- **Project location (in container):** `/home/rstudio/project`

## Daily Workflow

1. **Start:** `docker/start.bat` or `docker/start.sh`
2. **Work in RStudio:**
   - Open `smart-cfa.Rproj`
   - Edit `.qmd` files (e.g., `03-methods.qmd` for the R tutorial)
   - Run R code chunks in the console or directly in the `.qmd` files
   - Install new packages with `install.packages()` — `renv` tracks them automatically
   - Run `renv::snapshot()` after adding packages to update `renv.lock`
   - Render with `quarto render` in the Terminal
3. **Stop:** `docker/stop.bat` or `docker/stop.sh`

## Environment Features

- **Base image:** `rocker/verse:4.5.1` (R, RStudio Server, Quarto, Pandoc, TinyTeX)
- **R package management:** `renv` with lock file (`renv.lock`) for exact reproducibility
- **Key R packages:** `lavaan`, `semTools`, `semPlot`, and other CFA/SEM packages
- **LaTeX/TinyTeX:** Pre-installed for PDF rendering
- **Persistent volumes:** Project files, R packages (`renv` library/cache), RStudio settings

## Useful Commands

**Inside RStudio Terminal:**
```bash
quarto render                  # Render the entire manuscript
quarto render 03-methods.qmd   # Render a specific chapter
source("render_cleanup.R")     # Run post-render cleanup
```

**In your host terminal (inside `docker/` directory):**
```bash
docker-compose up -d      # Start container
docker-compose down       # Stop container
docker-compose build      # Rebuild image
docker-compose logs       # View container logs
```

**In R console:**
```r
renv::status()      # Check package consistency
renv::snapshot()    # Update renv.lock after adding packages
renv::restore()     # Restore packages from renv.lock
```

## Troubleshooting

- **Docker not running:** Start Docker Desktop before running the scripts.
- **Port in use:** The `start` scripts automatically find an available port — check terminal output for the URL.
- **Permission denied (Linux/macOS):** `chmod +x docker/start.sh docker/stop.sh`
- **Container fails to start:** Check logs with `cd docker && docker-compose logs`
- **Packages not found after restart:** Open `smart-cfa.Rproj` to activate `renv`, then run `renv::restore()`
- **`.Rprofile` error (`..md5..` not found):** Restart the R session after `renv::init()` completes

## Verify Reproducibility with MyBinder

To verify reproducibility without any local installation:

1. Click the **Binder** badge at the top of this page
2. Wait for the environment to build (~10–15 minutes on first run)
3. Open RStudio from the JupyterHub interface
4. Run `quarto render` in the Terminal
5. View the output in `docs/index.html`

This uses the exact configuration defined in `.binder/Dockerfile` and `renv.lock`. See [`.binder/README.md`](.binder/README.md) for details.

## Publishing / Deployment

The manuscript is automatically published to GitHub Pages via GitHub Actions (`.github/workflows/deploy.yml`) on every push to `main`.

To publish manually:

1. Ensure GitHub Pages is configured: **Settings → Pages → Source:** `gh-pages` branch, `/ (root)`
2. Run `quarto render` (generates `docs/`)
3. Commit and push to `main` — the workflow handles deployment to `gh-pages`
4. View the live site at `https://phdpablo.github.io/smart-cfa/`

## Citation

If you use or build upon this work, please cite:

Rogers, P., & Georgeto, S. M. (2024). Smart Choices for Measurement Models: Executable Manuscript Tutorial for your Confirmatory Factor Analysis in R Environment. <https://doi.org/10.31234/osf.io/2dy3z>

**BibTeX:**

```bibtex
@misc{rogers2024smartcfa,
  title  = {Smart Choices for Measurement Models: Executable Manuscript Tutorial
            for your Confirmatory Factor Analysis in R Environment},
  author = {Rogers, Pablo and Georgeto, S{\'e}rgio M.},
  year   = {2024},
  month  = jun,
  doi    = {10.31234/osf.io/2dy3z},
  url    = {https://doi.org/10.31234/osf.io/2dy3z},
  note   = {PsyArXiv Preprint}
}
```

This repository was built using the **ARTE** template. If you reuse the template infrastructure, please also cite:

Rogers, P., & Limongi, R. (2025). Open Science in Three Acts: Foundations, Practice, and Implementation - Third Act. *BAR - Brazilian Administration Review*, *22*(3), e250162. <https://doi.org/10.1590/1807-7692bar2025250162>

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/) — see the [LICENSE](LICENSE) file for details.
