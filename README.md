# Smart Choices for Measurement Models: Executable Manuscript Tutorial for your CFA in R Environment

[![Cite Preprint](https://img.shields.io/badge/Cite%20Preprint-PDF-red)](https://doi.org/10.31234/osf.io/2dy3z) [![TIER Protocol 4.0](https://img.shields.io/badge/TIER%20Protocol-4.0-green)](https://www.projecttier.org/tier-protocol/protocol-4-0/) [![GitHub Pages](https://img.shields.io/github/deployments/phdpablo/smart-cfa/github-pages?label=GitHub%20Pages)](https://phdpablo.github.io/smart-cfa/) [![OSF](https://img.shields.io/badge/OSF-10.31234/osf.io/2dy3z-blue)](https://doi.org/10.31234/osf.io/2dy3z) [![License](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/) [![R version](https://img.shields.io/badge/R-4.5.2-orange)](https://www.r-project.org/) [![Quarto](https://img.shields.io/badge/Quarto-1.6-orange)](https://quarto.org/) [![Docker](https://img.shields.io/badge/Docker-4.45.0-orange)](https://www.docker.com/) [![renv](https://img.shields.io/badge/renv-1.1.8-orange)](https://rstudio.github.io/renv/)

> Rogers, P., & Georgeto, S. M. (2024). *Smart Choices for Measurement Models: Executable Manuscript Tutorial for your Confirmatory Factor Analysis in R Environment.* <https://doi.org/10.31234/osf.io/2dy3z>

This repository contains the **complete reproducible materials** for the tutorial article on Confirmatory Factor Analysis (CFA) using R. The article guides applied social scientists through key decisions in CFA — from measurement model selection and power analysis to estimation, model fit, and modification — within a dynamic document framework that promotes open science principles (reproducibility, replicability, and transparency).

The manuscript is structured as a Quarto book and built using the [ARTE template](https://github.com/phdpablo/article-template) (Article Reproducibility Template & Environment). The live rendered version is available at: <https://phdpablo.github.io/smart-cfa/>

### Key Features

- ✅ **Comprehensive CFA guidelines** covering recommended practices, pitfalls, and reporting standards
- ✅ **Reproducible document** using Quarto with embedded R code (`lavaan` package)
- ✅ **Pre-rendered website** in `docs/` folder (GitHub Pages)
- ✅ **Docker environment** for computational reproducibility verification
- ✅ **TIER Protocol 4.0** compliant folder structure

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

## Access the Materials

| Resource | Description | Link |
| :-- | :-- | :-- |
| **📄 Preprint** | Original paper on PsyArXiv | [doi.org/10.31234/osf.io/2dy3z](https://doi.org/10.31234/osf.io/2dy3z) |
| **🌐 Tutorial Website** | Pre-rendered complete tutorial | [phdpablo.github.io/smart-cfa](https://phdpablo.github.io/smart-cfa/) |
| **🚀 MyBinder** | Run interactively in the cloud (no install) | [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/main?urlpath=rstudio) |
| **📦 Docker Image** | Self-contained reproducible environment | [hub.docker.com/r/phdpablo/smart-cfa](https://hub.docker.com/r/phdpablo/smart-cfa) |

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
├── docker/                # Docker configuration for reproducibility
├── .binder/               # Binder configuration for cloud interactive environment
└── docs/                  # Pre-rendered website (GitHub Pages)
```

Each subdirectory under `Data/`, `Scripts/`, and `Output/` contains a `README.md` with an overview, contents, and guidelines.

## Quick Start

### Option 1: View Pre-Rendered Website (Fastest)

Simply visit the deployed website — no installation needed:

**<https://phdpablo.github.io/smart-cfa/>**

The `gh-pages` branch of the repository contains the complete pre-rendered tutorial.

### Option 2: Cloud Interactive Environment (MyBinder)

Run the entire project in your browser without install anything. Ideal for quick exploration:
[![Launch RStudio on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/main?urlpath=rstudio)
*(Note: The first launch may take a few minutes as the environment is prepared.)*



### Option 4: Local Rendering

**Prerequisites:** R 4.5.2+, Quarto 1.8+

```bash
# Clone repository
git clone https://github.com/phdpablo/smart-cfa.git
cd smart-cfa

# Restore R packages
R -e "renv::restore()"

# Render the manuscript
quarto render
```

**Prerequisites:** [Docker Desktop](https://docs.docker.com/get-docker/)

```bash
cd docker
./start.sh         # macOS/Linux
start.bat          # Windows
```

Access RStudio Server at `http://127.0.0.1:8787` (no password). Then run `quarto render` in the RStudio Terminal to verify reproducibility.

See [`docker/README.md`](docker/README.md) for details.

## Docker Environment

The Docker setup is designed for **reproducibility verification**, not for daily development. A pre-built, self-contained image is published on Docker Hub (`phdpablo/smart-cfa:4.5.2`) with all project files, R packages, and LaTeX dependencies embedded.

**Key points:**

- The image is pulled from Docker Hub — no local build step is needed.
- All repository files are **already inside the image** — no volume mounting needed.
- The `Dockerfile` is included for transparency on how the image was built.
- On first start, LaTeX formats are synced (~30 seconds via `init-latex.sh`).

**Quick Docker commands:**
```bash
cd docker
docker compose up -d          # Start the container
docker compose stop           # Pause the container (data preserved)
docker compose down           # Stop and remove the container
```

**Or using Docker directly:**
```bash
docker pull phdpablo/smart-cfa:4.5.2
docker run -d --name smart-cfa -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true phdpablo/smart-cfa:4.5.2
```

## Publishing / Deployment

The manuscript is automatically published to GitHub Pages via GitHub Actions (`.github/workflows/deploy.yml`) on every push to `main`.

To publish manually:

1. Ensure GitHub Pages is configured: **Settings → Pages → Source:** `gh-pages` branch, `/ (root)`
2. Run `quarto render` (generates `docs/`)
3. Commit and push to `main` — the workflow handles deployment to `gh-pages`
4. View the live site at `https://phdpablo.github.io/smart-cfa/`

## Technical Details

**Software:** R 4.5.2 | Quarto 1.6 | Docker 4.45.0 | renv 1.1.8

**Key packages:** `lavaan`, `semTools`, `semPlot`, and other CFA/SEM packages

**Docker image:** `phdpablo/smart-cfa:4.5.2`

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
